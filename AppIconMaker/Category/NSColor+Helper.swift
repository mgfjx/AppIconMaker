//
//  NSColor+Helper.swift
//  AppIconMaker
//
//  Created by mgfjx on 2021/11/15.
//

import AppKit

extension NSColor {
    
    // MARK: hex color
    class func color(hexNumber: UInt64, alpha: CGFloat) -> NSColor {
        if (hexNumber > 0xFFFFFF) { return NSColor.clear }
        
        let red   = CGFloat(((hexNumber >> 16) & 0xFF)) / 255.0
        let green = CGFloat(((hexNumber >> 8) & 0xFF)) / 255.0
        let blue  = CGFloat((hexNumber & 0xFF)) / 255.0
        
        let color = NSColor.init(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    
    class func color(hexString: String, alpha: CGFloat) -> NSColor {
        let defaultColor = NSColor.clear
        
        if hexString.isEmpty {
            return defaultColor
        }
        
        var hexStr = hexString.uppercased()
        
        if hexStr.count < 6 {return defaultColor}
        if hexStr.hasPrefix("#") {
            hexStr = String(hexStr.suffix(from: "#".endIndex))
        }
        if hexStr.hasPrefix("0X") {
            hexStr = String(hexStr.suffix(from: "0X".endIndex))
        }
        
        guard let regular = try?NSRegularExpression.init(pattern: "[^A-F|^0-9]", options: .caseInsensitive) else {
            return defaultColor
        }
        let results = regular.matches(in: hexStr, options: .reportCompletion, range: NSMakeRange(0, hexStr.count))
        if results.count > 0 {return defaultColor}
        
        let scanner = Scanner.init(string: hexStr)
        let hexNumber = UnsafeMutablePointer<UInt64>.allocate(capacity: 0)
        if !scanner.scanHexInt64(hexNumber) {
            return defaultColor
        }
        let hex = hexNumber.pointee;
        
        return NSColor.color(hexNumber: hex, alpha: alpha)
    }
    
    class func color(hexString: String) -> NSColor {
        return NSColor.color(hexString: hexString, alpha: 1.0);
    }
    
    // MARK: random color
    class func randomColor(alpha: CGFloat) -> NSColor {
        let r = CGFloat(arc4random()%255)/255.0;
        let g = CGFloat(arc4random()%255)/255.0;
        let b = CGFloat(arc4random()%255)/255.0;
        return NSColor.init(red: r, green: g, blue: b, alpha: alpha);
    }
    
    class func randomColor() -> NSColor {
        return NSColor.randomColor(alpha: 1.0);
    }
    
}
