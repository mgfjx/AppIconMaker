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
    
    private init() {
        self.hotKey.keyDownHandler = {
          print("Pressed at \(Date())")
        }
    }
    
    func pause() {
        self.hotKey.isPaused = true
    }
    
    func resume() {
        self.hotKey.isPaused = false
    }
}
