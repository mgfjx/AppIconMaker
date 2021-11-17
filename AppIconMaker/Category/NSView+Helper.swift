//
//  NSView+Helper.swift
//  AppIconMaker
//
//  Created by mgfjx on 2021/11/8.
//

import Foundation
import AppKit

extension NSView {
    var backgroudColor: NSColor {
        set {
            if !self.wantsLayer {
                self.wantsLayer = true
            }
            self.layer?.backgroundColor = newValue.cgColor
        }
        get {
            if self.layer != nil && self.layer!.backgroundColor != nil {
                return NSColor.init(cgColor: self.layer!.backgroundColor!) ?? NSColor.clear
            } else {
                return NSColor.clear
            }
        }
    }
}
