//
//  AndroidModel.swift
//  AppIconMaker
//
//  Created by mgfjx on 2021/11/14.
//

import Foundation
import AppKit

class AndroidModel {
    
    var path: String = ""
    var width: CGFloat = 0
    var height: CGFloat = 0
    
    static func getConfigPath(type: AppIconType) -> String {
        let path = Bundle.main.path(forResource: "android", ofType: "json") ?? ""
        return path
    }
    
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
                let model = self.loadData(item: item)
                array.append(model)
            }
            return array
        } catch {
            print(error)
            return []
        }
    }
    
    static func loadData(item: [String: String]) -> AndroidModel {
        let model = AndroidModel.init()
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
    static func exportIcon(type: AppIconType, image: NSImage, path: String, complete: @escaping (Bool) -> Void){
        DispatchQueue.global().async {
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
