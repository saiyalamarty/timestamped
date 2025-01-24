//
//  timestampedApp.swift
//  timestamped
//
//  Created by Sai Yalamarty on 1/22/25.
//

import SwiftUI

@main
struct timestampedApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    static private(set) var instance: AppDelegate!
    lazy var statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var popover = NSPopover()
    let preferences = Preferences()
    var eventMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.instance = self

        // Configure the status bar item
        if let button = statusBarItem.button {
            button.image = NSImage(systemSymbolName: "clock", accessibilityDescription: nil)
            button.action = #selector(togglePopover(_:))
            button.target = self
        }

        // Set up the popover
        popover.behavior = .applicationDefined
        popover.contentViewController = NSHostingController(
            rootView: TimestampedView().environmentObject(preferences)
        )

        // Add event monitor for clicks outside the popover
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self = self, self.popover.isShown else { return }
            self.popover.performClose(event)
        }
    }

    deinit {
        if let eventMonitor = eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
        }
    }

    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            popover.performClose(sender)
        } else {
            focusMonitorAndShowPopover()
        }
    }
    
    func focusMonitorAndShowPopover() {
        guard let button = statusBarItem.button else { return }
        
        // Get the screen where the button is located
        let mouseLocation = NSEvent.mouseLocation
        
        // Find the screen containing the mouse click
        if let screen = NSScreen.screens.first(where: { $0.frame.contains(mouseLocation) }) {
            // Activate the screen by creating a dummy window
            let dummyWindow = NSWindow(
                contentRect: screen.frame,
                styleMask: [],
                backing: .buffered,
                defer: false
            )
            dummyWindow.makeKeyAndOrderFront(nil)
            dummyWindow.orderOut(nil)
            
            // Add a short delay to ensure focus happens before showing the popover
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        } else {
            // Default behavior if screen detection fails
            self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
}
