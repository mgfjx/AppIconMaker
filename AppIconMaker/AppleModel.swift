//
//  AppleModels.swift
//  AppIconMaker
//
//  Created by mgfjx on 2021/11/7.
//

import Foundation
import AppKit
import Cocoa

class AppleModel {
    
    var fileName: String = ""
    var width: CGFloat = 0
    var height: CGFloat = 0
    
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
        default:
            configName = ""
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
            let arr = AppleModel.loadiOSConfig(type: type)
            if arr.isEmpty {
                DispatchQueue.main.async {
                    complete(false)
                }
                return
            }
            for model in arr {
                image.reSize(resize: NSMakeSize(model.width, model.height), cornerRadius: 0).saveToPath(path: "\(path)/\(model.fileName)")
            }
            do {
                let contentFilePath = path + "/Contents.json"
                let jsonPath = AppleModel.getConfigPath(type: type)
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
            let jsonPath = AppleModel.getConfigPath(type: type)
            guard let data = NSData.init(contentsOfFile: jsonPath) else {
                print("获取不到.json文件!")
                return []
            }
            let obj = try JSONSerialization.jsonObject(with: data as Data, options: .allowFragments) as! [String: Any]
            let arr = (obj["images"] ?? []) as! [[String: String]]
            var array: [AppleModel] = []
            for item in arr {
                let model = AppleModel.loadData(item: item)
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
        let model = AppleModel.init()
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
