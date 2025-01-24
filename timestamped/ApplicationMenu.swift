//
//  ApplicationMenu.swift
//  timestamped
//
//  Created by Sai Yalamarty on 1/23/25.
//

import Foundation
import SwiftUI

class ApplicationMenu: NSObject {
    let menu = NSMenu()
    
    func createMenu() -> NSMenu {
        let timestampedView = TimestampedView()
        let hostingController = NSHostingController(rootView: timestampedView)
        hostingController.view.frame.size = CGSize(width: 360, height: 220)
        
        let customMenuItem = NSMenuItem()
        customMenuItem.view = hostingController.view
        
        menu.addItem(customMenuItem)
        
        return menu
    }
}
