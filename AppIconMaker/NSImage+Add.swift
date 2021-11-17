//
//  NSImage+Add.swift
//  AppIconMaker
//
//  Created by mgfjx on 2021/11/7.
//

import Foundation
import AppKit

extension NSImage {
    
    func saveToPath(path: String) {
        var imageData = self.tiffRepresentation!
        let imageReps = NSBitmapImageRep.imageReps(with: imageData)
        guard let imageRep: NSBitmapImageRep = imageReps.first as? NSBitmapImageRep else {
            print("no imageReps")
            return
        }
        let imageProps = [NSBitmapImageRep.PropertyKey.compressionFactor: 1.0]
        imageData = imageRep.representation(using: .png, properties: imageProps)!
        do {
            try imageData.write(to: URL.init(fileURLWithPath: path), options: Data.WritingOptions.atomic)
        } catch {
            print("保存失败!\(path), \(error)")
        }
    }
    
    func reSize(resize: NSSize, cornerRadius: CGFloat) -> NSImage {
        let newSize = NSSize.init(width: resize.width/2.0, height: resize.height/2.0)
        let newFrame = NSRect.init(x: 0, y: 0, width: newSize.width, height: newSize.height)
        let composedImage = NSImage(size: newSize)
        
        composedImage.lockFocus()
        let ctx = NSGraphicsContext.current
        ctx?.imageInterpolation = NSImageInterpolation.high
        
        let clipPath = NSBezierPath(roundedRect: newFrame, xRadius: cornerRadius, yRadius: cornerRadius)
        clipPath.windingRule = NSBezierPath.WindingRule.evenOdd
        clipPath.addClip()
        
        self.draw(in: newFrame, from: NSZeroRect, operation: .sourceOver, fraction: 1.0)
        composedImage.unlockFocus()
        
        return composedImage
    }
    
}
