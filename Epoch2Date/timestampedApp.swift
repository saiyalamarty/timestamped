//
//  timestampedApp.swift
//  timestamped
//
//  Created by Sai Yalamarty on 1/22/25.
//

import SwiftUI

@main
struct timestampedApp: App {
    let preferences = Preferences()
    
    var body: some Scene {
        MenuBarExtra("Timestamped", systemImage: "clock") {
            TimestampedView()
                .environmentObject(preferences)
        }
        .menuBarExtraStyle(.window)
    }
}
