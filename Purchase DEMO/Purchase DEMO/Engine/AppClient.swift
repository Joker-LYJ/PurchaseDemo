//
//  AppClient.swift
//  Purchase DEMO
//
//  Created by π³ on 2023/3/13.
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

//MARK: θ―·ζ±ζΉζ³
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
        print("ππ", (requestApi.api + (User.shared.userId ?? "") + timestamp))
        print("βοΈβοΈ", parameters)
        request(url, method: .post, parameters: parameters, key: key, timeout: timeout, responseHandler: response)
    }
}

//MARK: - ζ₯ε£θ―·ζ±
extension AppClient {
    /// User - create εε»Ίζ°η¨ζ·
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
                   
                    print("ERRORβοΈ", response?.url?.path)
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
    
    /// User - startup ζδΊ€η¨ζ·ε―ε¨δΏ‘ζ―οΌθΏεη¨ζ·εΊζ¬δΏ‘ζ―
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
        
        // ε·ε―ε¨ε»ΆθΏζΆι΄εηΉ
        let now = Double(Date().timeIntervalSince1970)
        
        post(.startUp, parameters: parameters) { data, success, response, error in
            if let data = data, let json = try? JSON(data: data) {
                print(json)
                // error msg
                if let msg = json["msg"].string {
//                    showDebugToast(text: msg)
                    print("ERRORβοΈ", response?.url?.path)
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
    
 
    /// Order - verify ζ ‘ιͺη¨ζ·ηθ?’ε
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
                 
                    print("msgβοΈ", response?.url?.path)
                    completion(false, nil)
                    return
                }
                print(json["data"])
                completion(true, json["data"])
                return
            } else {
                print("errorβοΈ", error?.localizedDescription)
                
            }
            completion(false, nil)
        }
    }
}


