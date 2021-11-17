//
//  PublicLoadingManager.swift
//  NewSeries
//
//  Created by mgfjx on 2020/12/26.
//

import AppKit

fileprivate var hubView: NSView?
fileprivate var activityIndicatorView: KRActivityIndicatorView?
class LoadingManager {
    
    class func show(onView: NSView) {
        
        if hubView != nil {
            hubView!.removeFromSuperview()
            hubView = nil
        }
        
        let bgSize:CGFloat = 100
        let itemSize:CGFloat = bgSize * 3.0/4
        
        let maskView = NSView.init(frame: NSMakeRect(0, 0, onView.frame.size.width, onView.frame.size.height))
//        maskView.center
        
        onView.addSubview(maskView)
        hubView = maskView
        
        let bgView = NSView.init(frame: NSMakeRect(0, 0, bgSize, bgSize))
        bgView.frame.origin = NSMakePoint((maskView.frame.width - bgSize)/2.0, (maskView.frame.height - bgSize)/2.0)
        bgView.wantsLayer = true
//        bgView.layer?.backgroundColor = NSColor.black.cgColor
        bgView.backgroudColor = NSColor.color(hexString: "#efefef")
        bgView.layer?.cornerRadius = bgSize*0.1
        maskView.addSubview(bgView)
        
        activityIndicatorView = KRActivityIndicatorView(frame: CGRect.init(x: 0, y: 0, width: itemSize, height: itemSize), type: .lineScale, color: NSColor.color(hexString: "#cccccc"), padding: 8)
        activityIndicatorView!.frame.origin = NSMakePoint((bgView.frame.width - itemSize)/2.0, (bgView.frame.height - itemSize)/2.0)
        bgView.addSubview(activityIndicatorView!)
        
        activityIndicatorView!.startAnimating()
    }
    
    class func hide(onView: NSView) {
        activityIndicatorView!.stopAnimating()
        hubView!.removeFromSuperview()
    }
    
}
