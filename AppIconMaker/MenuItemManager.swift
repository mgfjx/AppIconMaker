//
//  MenuItemManager.swift
//  AppIconMaker
//
//  Created by mgfjx on 2021/11/25.
//

import Cocoa

class MenuItemManager {
    static let manager: MenuItemManager = MenuItemManager.init()
    
    var menuEvent: ((_ menuItem: NSMenuItem) -> Void) = { _ in }
    
    private init() {
        
    }
    
}
