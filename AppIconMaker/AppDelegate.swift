//
//  AppDelegate.swift
//  AppIconMaker
//
//  Created by mgfjx on 2021/11/6.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            print("reopen")
            sender.windows.first?.makeKeyAndOrderFront(nil)
            return true
        } else {
            return false
        }
    }
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let arr = ProcessInfo.processInfo.arguments
            let config = NSWorkspace.OpenConfiguration()
            let str = filename
            let alert = NSAlert()
            alert.messageText = str
            alert.beginSheetModal(for: NSApplication.shared.windows.first!) { response in
            }
        }
        return true
    }
    
    
    @IBAction func menuItemClicked(_ sender: NSMenuItem) {
        MenuItemManager.manager.menuEvent(sender)
    }
    
}

