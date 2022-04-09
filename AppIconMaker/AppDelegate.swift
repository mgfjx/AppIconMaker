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
    
    func application(_ application: NSApplication, open urls: [URL]) {
        let urlStr = urls.first!.absoluteString
        let urlCode = urlStr.components(separatedBy: "//").last
        if urlCode == nil {
            return
        }
        let jsonString = urlCode!.removingPercentEncoding ?? ""
        do {
            let json: [String: String] = try JSONSerialization.jsonObject(with: jsonString.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions.fragmentsAllowed) as! [String : String]
            let imagePath = json["imagePath"] ?? ""
            NotificationCenter.default.post(name: NSNotification.Name("receiveImagePathkey"), object: imagePath)
        } catch {
            let errStr = error.localizedDescription
            print(errStr)
        }
    }
    
    @IBAction func menuItemClicked(_ sender: NSMenuItem) {
        MenuItemManager.manager.menuEvent(sender)
    }
    
}

