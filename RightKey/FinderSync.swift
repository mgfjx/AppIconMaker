//
//  FinderSync.swift
//  RightKey
//
//  Created by mgfjx on 2021/11/28.
//

import Cocoa
import FinderSync

class FinderSync: FIFinderSync {

    var myFolderURL = URL(fileURLWithPath: "/")
    
    var targetImage: NSImage?
    
    override init() {
        super.init()
        
        NSLog("FinderSync() launched from %@", Bundle.main.bundlePath as NSString)
        
        // Set up the directory we are syncing.
        FIFinderSyncController.default().directoryURLs = [self.myFolderURL]
        
        // Set up images for our badge identifiers. For demonstration purposes, this uses off-the-shelf images.
        FIFinderSyncController.default().setBadgeImage(NSImage(named: NSImage.colorPanelName)!, label: "Status One" , forBadgeIdentifier: "One")
        FIFinderSyncController.default().setBadgeImage(NSImage(named: NSImage.cautionName)!, label: "Status Two", forBadgeIdentifier: "Two")
    }
    
    // MARK: - Primary Finder Sync protocol methods
    
    override func beginObservingDirectory(at url: URL) {
        // The user is now seeing the container's contents.
        // If they see it in more than one view at a time, we're only told once.
        NSLog("beginObservingDirectoryAtURL: %@", url.path as NSString)
    }
    
    
    override func endObservingDirectory(at url: URL) {
        // The user is no longer seeing the container's contents.
        NSLog("endObservingDirectoryAtURL: %@", url.path as NSString)
    }
    
    override func requestBadgeIdentifier(for url: URL) {
        NSLog("requestBadgeIdentifierForURL: %@", url.path as NSString)
        
        // For demonstration purposes, this picks one of our two badges, or no badge at all, based on the filename.
        let whichBadge = abs(url.path.hash) % 3
        let badgeIdentifier = ["", "One", "Two"][whichBadge]
        FIFinderSyncController.default().setBadgeIdentifier(badgeIdentifier, for: url)
    }
    
    // MARK: - Menu and toolbar item support
    
    override var toolbarItemName: String {
        return "RightKey"
    }
    
    override var toolbarItemToolTip: String {
        return "RightKey"
    }
    
    override var toolbarItemImage: NSImage {
        let toolBarImage = NSImage(named: "MagicIcon")!
        toolBarImage.isTemplate = true
        return toolBarImage
    }
    
    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        // Produce a menu for the extension.
        switch menuKind {
        case .contextualMenuForItems: //右键单击
            return self.fileMenu()
        case .contextualMenuForContainer: //右键点击文件夹空白背景
            return self.directoryMenu()
        case .contextualMenuForSidebar:
            let menu = NSMenu(title: "Mgfjx0")
            menu.addItem(withTitle: "Mgfjx0", action: #selector(sampleAction(_:)), keyEquivalent: "")
            return menu
        case .toolbarItemMenu:
            return NSMenu.init()
        @unknown default:
            return NSMenu.init()
        }
    }
    
    @IBAction func sampleAction(_ sender: AnyObject?) {
        let target = FIFinderSyncController.default().targetedURL()
        let items = FIFinderSyncController.default().selectedItemURLs()
        
        let item = sender as! NSMenuItem
        NSLog("sampleAction: menu item: %@, target = %@, items = ", item.title as NSString, target!.path as NSString)
        for obj in items! {
            NSLog("    %@", obj.path as NSString)
        }
    }
    
    /// 右键点击file
    func fileMenu() -> NSMenu {
        
        let items = FIFinderSyncController.default().selectedItemURLs() ?? []
        let url = items.first!
        let suffix = url.pathExtension
        let images = ["png", "jpg", "jpeg"]
        if !images.contains(suffix.lowercased()) {
            return NSMenu.init()
        }
        
        let menu = NSMenu(title: "AppIconMaker")
        let menuItem = NSMenuItem.init(title: "AppIconMaker", action: #selector(itemClicked(_:)), keyEquivalent: "")
        let subMenu = NSMenu(title: "AppIconMaker")
        do {
            let titles = ["iPhone/iPad", "MacOS", "iWatch", "Android", "All"]
            for i in 0..<titles.count {
                let item = NSMenuItem.init(title: titles[i], action: #selector(itemClicked(_:)), keyEquivalent: "")
                item.tag = i
                subMenu.addItem(item)
            }
        }
        menu.addItem(menuItem)
        menuItem.submenu = subMenu
        return menu
    }
    
    /// 右键点击文件夹
    func directoryMenu() -> NSMenu {
        let menu = NSMenu(title: "Mgfjx2")
        menu.addItem(withTitle: "当前点击的是文件夹背景", action: #selector(sampleAction(_:)), keyEquivalent: "")
        return menu
    }
    
    
    @objc func itemClicked(_ item: NSMenuItem) {
        let target = FIFinderSyncController.default().targetedURL()
        let items = FIFinderSyncController.default().selectedItemURLs()!
        
        var image: NSImage?
        if items.count == 1 {
            do {
                let imageData = try Data.init(contentsOf: items.first!)
                image = NSImage.init(data: imageData)
            } catch {
                let errStr = error.localizedDescription
                print(errStr)
            }
        }
        
        if image == nil {
            return
        }
        
        let path = target!.path
        var type: AppIconType = .iOS
        switch item.tag {
        case 0:
            type = .iOS
        case 1:
            type = .Mac
        case 2:
            type = .Watch
        case 3:
            type = .Android
        default:
            type = .All
        }
        AppIconMaker.exportIcon(type: type, image: image!, directory: path) { (complete, filePath) in
            NSWorkspace.shared.open(URL.init(fileURLWithPath: filePath))
        }
    }

}

