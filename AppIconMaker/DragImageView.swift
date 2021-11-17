//
//  DragImageView.swift
//  AppIconMaker
//
//  Created by mgfjx on 2021/11/6.
//

import Cocoa

class DragImageView: NSImageView {
    
    var imageDroped: (NSImage?) -> Void = { _ in }
    var dragEntered: () -> Void = {  }
    var dragExited: () -> Void = {  }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.registerForDraggedTypes([.fileURL])
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.registerForDraggedTypes([.fileNameType(forPathExtension: "png")])
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
//        NSColor.init(red: 0.3, green: 0.8, blue: 0.2, alpha: 1.0).setFill()
//        dirtyRect.fill()
    }
    
    override var intrinsicContentSize: NSSize {
        get {
            return NSSize.init(width: NSView.noIntrinsicMetric, height: NSView.noIntrinsicMetric)
        }
    }
    
}

extension DragImageView {
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        print("拖拽文件进入当前view")
        self.dragEntered()
        let sourceDragMask = sender.draggingSourceOperationMask
        let pboard = sender.draggingPasteboard
        let type = NSPasteboard.PasteboardType.fileURL
        if pboard.types!.contains(type) {
            print("包含")
            if sourceDragMask.contains(NSDragOperation.link) {
                return NSDragOperation.link
            } else if sourceDragMask.contains(NSDragOperation.copy) {
                return NSDragOperation.copy
            }
        }
        return NSDragOperation.init(rawValue: 0)
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        self.dragExited()
    }
    
    //拖拽结束
    override func draggingEnded(_ sender: NSDraggingInfo) {
        print("sb")
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pboard = sender.draggingPasteboard
        print("drop now")
        let type = NSPasteboard.PasteboardType.fileURL
        if pboard.types!.contains(type) {
            let path = (pboard.propertyList(forType: .fileURL) ?? "") as! String
            if path.count > 0 {
                let image = NSImage.init(pasteboard: pboard)
                self.imageDroped(image);
                return true
            } else {
                print("文件路径不存在")
            }
        } else {
            print("文件路径不存在")
        }
        return false
    }
    
    
}
