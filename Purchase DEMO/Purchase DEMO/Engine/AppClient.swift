//
//  AppClient.swift
//  Purchase DEMO
//
//  Created by 🐳 on 2023/3/13.
//


import Foundation
import CryptoSwift
import SwiftyJSON
import Combine

enum LaunchType: String {
    case cold, hot, notification
}

enum Environment {
    case develop, product
    
    var baseURL: String {
        switch self {
        case .develop:
            return "http://192.168.50.89:5000"
        case .product:
            return "https://api.highlightee.com"
        }
    }
    
}

class AppClient: NSObject {
    static let shared = AppClient()
    
    let environment: Environment = .develop
    
    private var baseURL: String {
        return environment.baseURL
    }
}

//MARK: 请求方法
extension AppClient {
    /// POST Request
    func post(_ requestApi: HttpRequestAPI,
              parameters: HttpParameters?,
              timeout: TimeInterval = 90,
              response: Response) {
        let timestamp: String = String(Int64(Date().timeIntervalSince1970 * 1000))
        // query
        let querys: HttpParameters? = [
            "id" : User.shared.userId,
            "timestamp" : timestamp
        ]
        // url
        let url = baseURL + requestApi.url(querys: querys)
        // key
        let key = (requestApi.api + (User.shared.userId ?? "") + timestamp).bytes.sha256()
        print("🔑🔑", (requestApi.api + (User.shared.userId ?? "") + timestamp))
        print("✍️✍️", parameters)
        request(url, method: .post, parameters: parameters, key: key, timeout: timeout, responseHandler: response)
    }
}

//MARK: - 接口请求
extension AppClient {
    /// User - create 创建新用户
    func create(completion: (()->Void)? = nil) {
        let parameters: HttpParameters? = [
            "region_code" : Util.countryCode(),
            "language_code" : Util.languageCode()
        ]
        
        post(.create, parameters: parameters) { data, success, response, error in
            if let data = data, let json = try? JSON(data: data) {
                print(json)
                // error msg
                if let msg = json["msg"].string {
                   
                    print("ERROR❗️", response?.url?.path)
                }
                if let userId = json["data"].string {
                    UserRecorder.userID = userId
                    completion?()
                }
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    
    /// User - startup 提交用户启动信息，返回用户基本信息
    func startUp(_ launchType: LaunchType) {
        let parameters: HttpParameters? = [
            "launch_type" : launchType.rawValue,
            "region_code" : Util.countryCode(),
            "language_code" : Util.languageCode(),
            "app_version" : Util.appVersion(),
            "os": "iOS",
            "os_version" : UIDevice.current.systemVersion,
            "device" : Util.getDeviceVersion(),
        ]
        
        // 冷启动延迟时间埋点
        let now = Double(Date().timeIntervalSince1970)
        
        post(.startUp, parameters: parameters) { data, success, response, error in
            if let data = data, let json = try? JSON(data: data) {
                print(json)
                // error msg
                if let msg = json["msg"].string {
//                    showDebugToast(text: msg)
                    print("ERROR❗️", response?.url?.path)
                    // ERROR DelayStartUp
                    if launchType == .cold {
//                        Statistics.delayEvent(seconds: -1)
                    }
                }
                
                if launchType == .cold {
                    let delay = Double(Date().timeIntervalSince1970) - now
//                    Statistics.delayEvent(seconds: delay)
                }
            } else {
                // ERROR DelayStartUp
                if launchType == .cold {
//                    Statistics.delayEvent(seconds: -1)
                }
//                showDebugToast(text: error?.localizedDescription)
            }
        }
    }
    
 
    /// Order - verify 校验用户的订单
    func verifyOrder(receiptData: String, completion: @escaping ((Bool, JSON?)->Void) ) {
        let parameters: HttpParameters? = [
            "user_id" : User.shared.userId,
            "receipt_data" : receiptData
        ]
        
        post(.verify, parameters: parameters) { data, success, response, error in
            if let data = data, let json = try? JSON(data: data) {
                print(json)
                // error msg
                if let msg = json["msg"].string {
                 
                    print("msg❗️", response?.url?.path)
                    completion(false, nil)
                    return
                }
                print(json["data"])
                completion(true, json["data"])
                return
            } else {
                print("error❗️", error?.localizedDescription)
                
            }
            completion(false, nil)
        }
    }
}


