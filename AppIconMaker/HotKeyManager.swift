//
//  HotKeyManager.swift
//  AppIconMaker
//
//  Created by mgfjx on 2021/11/24.
//

import Foundation
import HotKey

class HotKeyManager {
    static let manager: HotKeyManager = HotKeyManager.init()
    //加载快捷键
    let hotKey = HotKey(key: .r, modifiers: [.command])
    
    var keyHandler: () -> Void = {   }
    
    private init() {
        self.hotKey.keyDownHandler = { [weak self] in
            self?.keyHandler()
        }
    }
    
    func pause() {
        self.hotKey.isPaused = true
    }
    
    func resume() {
        self.hotKey.isPaused = false
    }
}
