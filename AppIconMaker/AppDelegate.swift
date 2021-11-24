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
            HotKeyManager.manager.resume()
            sender.windows.first?.makeKeyAndOrderFront(nil)
            return true
        } else {
            return false
        }
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        HotKeyManager.manager.resume()
    }
    
    func applicationDidResignActive(_ notification: Notification) {
        HotKeyManager.manager.pause()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        HotKeyManager.manager.pause()
        return false
    }
    
    @IBAction func menuItemClicked(_ sender: NSMenuItem) {
        MenuItemManager.manager.menuEvent(sender)
    }
}

