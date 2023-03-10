//
//  Recorder.swift
//  Purchase DEMO
//
//  Created by 🐳 on 2023/3/9.
//

import Foundation
import MMKV


class Recoder {
    
    static let mmkv = MMKV(mmapID: K.MMKVID, rootPath: K.Path.document.path) //其中mmapID表示多进程共享内存的ID，cryptKey表示加密密钥，如果不需要加密可以传nil。对于多进程模式，需要在不同的进程中使用相同的mmapID和cryptKey才能实现数据共享。
    
    
    
    static var PurchaseInfomation: PurchaseModel? {
        set {
            guard let mmkv = self.mmkv else { return }
            // 将模型对象转换为字符串
            let encoder = JSONEncoder()
            guard let data = try? encoder.encode(newValue), let userString = String(data: data, encoding: .utf8) else { return }
            // 存储字符串
            mmkv.set(userString, forKey: "PurchasePice")
        }
        get {
            guard let mmkv = self.mmkv else { return nil }
            if let retrievedUserString = mmkv.string(forKey: "PurchasePice") {
                   // 将字符串转换为模型对象
                   let decoder = JSONDecoder()
                guard let retrievedData = retrievedUserString.data(using: .utf8), let retrievedUser = try? decoder.decode(PurchaseModel.self, from: retrievedData) else { return nil }
                   return retrievedUser
               }
            return nil
        }
    }
    
    static var vipExpireDate: Date {
        set {
            guard let mmkv = self.mmkv else { return }
            mmkv.set(newValue, forKey: "vipExpireDate")
        }
        get {
            let defaultDate = Date(timeIntervalSince1970: 0.0)
            guard let mmkv = self.mmkv else { return defaultDate }
            return mmkv.date(forKey: "vipExpireDate", defaultValue: defaultDate) ?? defaultDate
        }
    }
}
