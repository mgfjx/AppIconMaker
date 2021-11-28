//
//  AppIconMaker.swift
//  AppIconMaker
//
//  Created by mgfjx on 2021/11/29.
//

import Foundation
import AppKit
import Cocoa

enum AppIconType {
    case iOS
    case Mac
    case Watch
    case Android
}

/// 苹果设备数据模型
struct AppleModel {
    var fileName: String = ""
    var width: CGFloat = 0
    var height: CGFloat = 0
}

/// 安卓设备数据模型
struct AndroidModel {
    var path: String = ""
    var width: CGFloat = 0
    var height: CGFloat = 0
}

class AppIconMaker {
    
    static func getConfigPath(type: AppIconType) -> String {
        let configName: String
        switch type {
        case .iOS:
            configName = "iOS"
        case .Mac:
            configName = "mac"
        case .Watch:
            configName = "watch"
        case .Android:
            configName = "android"
        }
        let path = Bundle.main.path(forResource: configName, ofType: "json") ?? ""
        return path
    }
    
    /// 导出iOS图标到path
    /// - Parameters:
    ///   - type: 类型
    ///   - image: 原图片文件
    ///   - path: 导出地址
    ///   - complete: 导出回调
    static func exportIcon(type: AppIconType, image: NSImage, path: String, complete: @escaping (Bool) -> Void){
        DispatchQueue.global().async {
            
            if FileManager.default.fileExists(atPath: path) {
                do {
                    try FileManager.default.removeItem(atPath: path)
                } catch {
                    print("删除路径失败: \(error)")
                }
            }
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("创建路径失败: \(error)")
            }
            
            let arr = AppIconMaker.loadiOSConfig(type: type)
            if arr.isEmpty {
                DispatchQueue.main.async {
                    complete(false)
                }
                return
            }
            for model in arr {
                DispatchQueue.global().async {
                    image.reSize(resize: NSMakeSize(model.width, model.height), cornerRadius: 0).saveToPath(path: "\(path)/\(model.fileName)")
                }
            }
            do {
                let contentFilePath = path + "/Contents.json"
                let jsonPath = AppIconMaker.getConfigPath(type: type)
                try FileManager.default.copyItem(atPath: jsonPath, toPath: contentFilePath)
            } catch {
                print("拷贝配置文件失败: \(error)")
            }
            DispatchQueue.main.async {
                complete(true)
            }
        }
    }
    
    /// 加载iOS.json文件
    static func loadiOSConfig(type: AppIconType) -> [AppleModel]{
        do {
            let jsonPath = AppIconMaker.getConfigPath(type: type)
            guard let data = NSData.init(contentsOfFile: jsonPath) else {
                print("获取不到.json文件!")
                return []
            }
            let obj = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as! [String: Any]
            let arr = (obj["images"] ?? []) as! [[String: String]]
            var array: [AppleModel] = []
            for item in arr {
                let model = self.loadData(item: item)
                array.append(model)
            }
            return array
        } catch {
            print(error)
            return []
        }
    }
    
    //加载苹果设备模型
    static func loadData(item: [String: String]) -> AppleModel {
        var model = AppleModel.init()
        let filename = item["filename"] ?? ""
        let idiom = item["idiom"] ?? ""
        let scale = item["scale"] ?? ""
        let size = item["size"] ?? ""
        print("idiom: \(idiom), scale: \(scale), size: \(size), filename: \(filename)")
        
        model.fileName = filename
        let scaleFloat: CGFloat = CGFloat((scale.dropLast() as NSString).floatValue)
        
        let sizeArr = size.components(separatedBy: "x")
        if sizeArr.count != 2 {
            print("当前配置出错!\(filename): \(sizeArr)")
            return AppleModel.init()
        }
        model.width = CGFloat((sizeArr.first! as NSString).floatValue) * scaleFloat
        model.height = CGFloat((sizeArr.last! as NSString).floatValue) * scaleFloat
        return model
    }
}

/// 处理安卓设备
extension AppIconMaker {
    
    /// 加载android.json文件
    static func loadConfig() -> [AndroidModel]{
        do {
            let jsonPath = self.getConfigPath(type: .Android)
            guard let data = NSData.init(contentsOfFile: jsonPath) else {
                print("获取不到.json文件!")
                return []
            }
            let arr = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as! [[String: String]]
            var array: [AndroidModel] = []
            for item in arr {
                let model = self.loadAndroidData(item: item)
                array.append(model)
            }
            return array
        } catch {
            print(error)
            return []
        }
    }
    
    static func loadAndroidData(item: [String: String]) -> AndroidModel {
        var model = AndroidModel.init()
        let path = item["path"] ?? ""
        let size = item["size"] ?? ""
        print("path: \(path), size: \(size)")
        
        model.path = path
        let sizeArr = size.components(separatedBy: "x")
        if sizeArr.count != 2 {
            print("当前配置出错!\(path): \(sizeArr)")
            return AndroidModel.init()
        }
        model.width = CGFloat((sizeArr.first! as NSString).floatValue)
        model.height = CGFloat((sizeArr.last! as NSString).floatValue)
        return model
    }
    
    /// 导出Android图标到path
    static func exportAndroidIcon(type: AppIconType, image: NSImage, path: String, complete: @escaping (Bool) -> Void){
        DispatchQueue.global().async {
            
            if FileManager.default.fileExists(atPath: path) {
                do {
                    try FileManager.default.removeItem(atPath: path)
                } catch {
                    print("删除路径失败: \(error)")
                }
            }
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("创建路径失败: \(error)")
            }
            
            let arr = self.loadConfig()
            if arr.isEmpty {
                DispatchQueue.main.async {
                    complete(false)
                }
                return
            }
            for model in arr {
                let directryPath = "\(path)/\(model.path)/"
                do {
                    try FileManager.default.createDirectory(at: URL.init(fileURLWithPath: directryPath), withIntermediateDirectories: false, attributes: nil)
                    let newSize = NSMakeSize(model.width, model.height)
                    image.reSize(resize: newSize, cornerRadius: 0).saveToPath(path: "\(directryPath)ic_launcher.png")
                    image.reSize(resize: newSize, cornerRadius: newSize.width/2.0).saveToPath(path: "\(directryPath)ic_launcher_round.png")
                } catch {
                    print(error)
                }
                
            }
            DispatchQueue.main.async {
                complete(true)
            }
        }
    }
}
