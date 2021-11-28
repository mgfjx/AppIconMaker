//
//  MainViewController.swift
//  AppIconMaker
//
//  Created by mgfjx on 2021/11/6.
//

import Cocoa
import SnapKit

let kExportPathKey: String = "kExportPathKey"
let kLastImagePathKey: String = "kLastImagePathKey"
let kDeviceSelectedKey: String = "kDeviceSelectedKey"
let lastImagePath: String = NSTemporaryDirectory() + "/lastImage.png"

let holderColor = NSColor.color(hexString: "#dddddd")
let takedColor = NSColor.clear

class XLPathControl: NSPathControl {
    override var intrinsicContentSize: NSSize {
        get {
            return NSSize.init(width: NSView.noIntrinsicMetric, height: NSView.noIntrinsicMetric)
        }
    }
}

class MainViewController: NSViewController {
    
    @IBOutlet weak var popUpBtn: NSPopUpButton!
    @IBOutlet weak var imageView: DragImageView!
    @IBOutlet weak var pathControl: NSPathControl!
    @IBOutlet weak var slider: NSSlider!
    @IBOutlet weak var sliderLabel: NSTextField!
    @IBOutlet weak var exportBtn: NSButton!
    
    var originImage: NSImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //默认选中第一个
        let selectedIndex = UserDefaults.standard.integer(forKey: kDeviceSelectedKey)
        self.popUpBtn.selectItem(at: selectedIndex)
        self.sliderLabel.stringValue = String(format: "%.1f", self.slider.floatValue) + "%"
        self.exportBtn.image = NSImage.init(named: "export_icon")
        
        //配置imageView
        self.configImageView()
        
        //默认输出路径
        let path = UserDefaults.standard.string(forKey: kExportPathKey)
        if path != nil {
            self.pathControl.url = URL.init(fileURLWithPath: path!)
        } else {
            self.pathControl.url = URL.init(fileURLWithPath: NSHomeDirectory() + "/Desktop/AppIcon")
        }
        
        //加载上次处理图片
        print("store path: \(lastImagePath)")
        let image = NSImage.init(contentsOfFile: lastImagePath)
        if image != nil {
            self.originImage = image
            self.imageView.image = image
            self.imageView.backgroudColor = takedColor
            self.resetConfig()
        }
        
        MenuItemManager.manager.menuEvent = { [weak self] menuItem in
            
            switch menuItem.tag {
            case 100:
                self?.selectImageFromFinder()
                break
            case 101:
                self?.saveFilesTo(nil)
                break
            case 102:
                self?.selectExportPath(nil)
                break
            case 103:
                self?.popUpBtn.sendAction(on: NSEvent.EventTypeMask.keyDown)
                break
            default:
                break
            }
        }
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func configImageView() {
        let tap = NSClickGestureRecognizer.init(target: self, action: #selector(selectImageFromFinder))
        self.imageView.addGestureRecognizer(tap)
        self.imageView.backgroudColor = holderColor //设置为加载图片时的背景色
        self.imageView.imageDroped = { [weak self] image in
            self?.showAlertByImage(image: image)
            self?.imageView.image = image
            if image != nil {
                //当前图片做本地保存
                image!.saveToPath(path: lastImagePath)
                self?.originImage = image
                self?.imageView.backgroudColor = takedColor
                self?.resetConfig()
            } else {
                self?.imageView.backgroudColor = holderColor
            }
        }
        self.imageView.dragEntered = { [weak self] in
            self?.imageView.backgroudColor = takedColor
        }
        
        self.imageView.dragExited = { [weak self] in
            self?.imageView.backgroudColor = holderColor
        }
    }
    
    func loadConfigData() {
        
        guard let image = self.imageView.image else {
            print("请添加图片!")
            let alert = NSAlert()
            alert.messageText = "请添加图片!"
            alert.beginSheetModal(for: self.view.window!) { response in
            }
            return
        }
//        let path = self.pathLabel.stringValue + "/AppIconMaker"
        let path = self.pathControl.url!.path + "/AppIconMaker"
        
        var type: AppIconType
        switch self.popUpBtn.indexOfSelectedItem {
        case 0:
            type = .iOS
        case 1:
            type = .Mac
        case 2:
            type = .Watch
        case 3:
            type = .Android
        default:
            type = .iOS
        }
        
        if type == .Android {
            LoadingManager.show(onView: self.view)
            AndroidModel.exportIcon(type: type, image: image, path: path) { complete in
                print(complete ? "导出成功!" : "导出失败!")
                NSWorkspace.shared.open(URL.init(fileURLWithPath: path))
                LoadingManager.hide(onView: self.view)
                
            }
        } else {
            LoadingManager.show(onView: self.view)
            AppleModel.exportIcon(type: type, image: image, path: path) { complete in
                print(complete ? "导出成功!" : "导出失败!")
                NSWorkspace.shared.open(URL.init(fileURLWithPath: path))
                LoadingManager.hide(onView: self.view)
            }
        }
        self.showLoaclNotification()
    }
    
    @IBAction func saveFilesTo(_ sender: NSButton?) {
        UserDefaults.standard.set(self.popUpBtn.indexOfSelectedItem, forKey: kDeviceSelectedKey)
        self.loadConfigData()
    }
    
    @objc func selectImageFromFinder() {
        let openPanel = NSOpenPanel.init()
        openPanel.allowsMultipleSelection = false;
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.message = "选择图片"
        openPanel.prompt = "选择"
        
        //使用上次打开图片的路径，如果没有则使用默认路径
        let lastImageUrl = UserDefaults.standard.url(forKey: kLastImagePathKey)
        if lastImageUrl != nil {
            if FileManager.default.fileExists(atPath: lastImageUrl!.path) {
                openPanel.directoryURL = lastImageUrl!
            } else {
                let url = lastImageUrl!.deletingLastPathComponent()
                if FileManager.default.fileExists(atPath: url.path) {
                    openPanel.directoryURL = url
                } else {
                    openPanel.directoryURL = URL.init(string: NSHomeDirectory())
                }
            }
        } else {
            openPanel.directoryURL = URL.init(string: NSHomeDirectory())
        }
        
        openPanel.begin(completionHandler: { (result) in
            if result == NSApplication.ModalResponse.OK {
                for url in openPanel.urls {
                    let image = NSImage.init(contentsOfFile: url.path)
                    self.imageView.image = image
                    self.showAlertByImage(image: image)
                    //如果图片存在则记录图片的路径
                    if image != nil {
                        //当前图片做本地保存
                        image!.saveToPath(path: lastImagePath)
                        self.originImage = image
                        UserDefaults.standard.set(url, forKey: kLastImagePathKey)
                        self.imageView.backgroudColor = takedColor
                        self.resetConfig()
                    } else {
                        self.imageView.backgroudColor = holderColor
                    }
                    break
                }
            }
        })
        
    }
    
    @IBAction func selectExportPath(_ sender: NSPathControl?) {
        let openPanel = NSOpenPanel.init()
        openPanel.allowsMultipleSelection = false;
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.message = "选择输出路径"
        openPanel.prompt = "选择"
        let path = self.pathControl.url!.path
        if path.count > 0 {
            openPanel.directoryURL = URL.init(string: path);
        } else {
            openPanel.directoryURL = URL.init(string: NSHomeDirectory());
        }
        openPanel.begin(completionHandler: { (result) in
            if result == NSApplication.ModalResponse.OK {
                for url in openPanel.urls {
                    self.saveExpordPath(url: url)
                    break
                }
            }
        })
    }
    
    /// 保存导出路径
    func saveExpordPath(url: URL) {
        let path = url.path
        if path.count == 0 {
            return
        }
        self.pathControl.url = url
        UserDefaults.standard.set(path, forKey: kExportPathKey)
    }
    
    func showAlertByImage(image: NSImage?) {
        
        var msg = ""
        if image == nil {
            msg = "当前文件不是图片类型"
        } else {
            let image = image!
            let imageRep = NSBitmapImageRep.init(data: image.tiffRepresentation!)!
            let height = imageRep.pixelsHigh
            let width = imageRep.pixelsWide
            if height != width {
                msg = "图片宽高不相等"
            } else if height < 1024 {
                msg = "图片大小小于1024"
            }
        }
        
        if msg.count > 0 {
            let alert = NSAlert()
            alert.messageText = msg
            alert.beginSheetModal(for: self.view.window!) { response in
                
            }
        }
        
    }
    
    @IBAction func sliderChanged(_ sender: NSSlider) {
        self.sliderLabel.stringValue = String(format: "%.1f", self.slider.floatValue) + "%"
        guard let image = self.originImage else {
            return
        }
        DispatchQueue.main.async {
            let imageRep = NSBitmapImageRep.init(data: image.tiffRepresentation!)!
            let height = imageRep.pixelsHigh
            let width = imageRep.pixelsWide
            let radius = CGFloat(width) * CGFloat(self.slider.floatValue/200.0)
            let resizeImg = image.reSize(resize: NSSize.init(width: width, height: height), cornerRadius: radius)
            self.imageView.image = resizeImg
        }
    }
    
    func resetConfig() {
        self.slider.intValue = 0
        self.sliderLabel.stringValue = String(format: "%.1f", self.slider.floatValue) + "%"
    }
    
    /// 发送本地通知
    func showLoaclNotification() {
        let notification = NSUserNotification.init()
        notification.title = "导出成功!"
        notification.informativeText = "导出路径为：\(self.pathControl.url!.absoluteString)"
        notification.deliveryDate = Date.init(timeIntervalSinceNow: 0)
        NSUserNotificationCenter.default.delegate = self
        NSUserNotificationCenter.default.scheduleNotification(notification)
    }
}

extension MainViewController: NSUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
}

