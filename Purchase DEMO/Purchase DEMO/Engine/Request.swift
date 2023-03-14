//
//  Request.swift
//  Purchase DEMO
//
//  Created by 🐳 on 2023/3/13.
//

import Foundation
import SwiftyJSON
import CryptoSwift
import Alamofire

public enum RequestMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
}

public typealias HttpParameters = [String: Any?]
//public typealias HttpRequestHeaders = [String: String]
public typealias Response = ((Data?, Bool, HTTPURLResponse?, Error?) -> Void)?



public func request(_ url: String,
                    method: HTTPMethod,
                    parameters: Parameters? = nil,
                    headers: HTTPHeaders? = nil,
                    key: [UInt8]? = nil,
                    timeout: TimeInterval,
                    responseHandler: Response) {

    AF.request(url, method: method, requestModifier: { request in
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = timeout
        switch method {
        case .put,.post:
            if let parameters = parameters {
                let contentType = headers?["Content-Type"]
                
                if contentType == nil {
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                }
                
                if contentType == "application/json" || contentType == nil {
                    do {
                        if let key = key {
                            let data = try JSONSerialization.data(withJSONObject: parameters)
                            if let AES = try? AES (key: key, blockMode: ECB(), padding: .pkcs7) {
                                let body = try AES.encrypt(data.bytes)
                                request.httpBody = try? JSON(["data": body] as Any).rawData()
                            }
                        } else {
                            request.httpBody = try? JSON(parameters as Any).rawData()
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                else if contentType == "application/x-www-form-urlencoded" {
                    let components = parameters.map { (k, v) -> String in
                        return "\(k)=\(v)"
                    }
                    request.httpBody = components.joined(separator: "&").data(using: .utf8)
                }
                else {
                    print(#function, "Unsupported Content-Type")
                }
            }
          
        case .get:
            break
        default:
            break
        }
        print(request.url)
        
    }).response { response in
        if let data = response.data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    // 处理JSON对象
                    print(json)
                } catch {
                    // JSON解析错误
                    print(error.localizedDescription)
                }
            } else {
                // 请求失败，获取到错误信息
                print(response.error?.localizedDescription ?? "Unknown error")
            }
    }
    
}

// reponseHandler: (data, success, response, error) -> Void
//public func request(_ url: URL?,
//                    method: RequestMethod,
//                    parameters: HttpParameters? = nil,
//                    querys: HttpParameters? = nil,
//                    headers: HttpRequestHeaders? = nil,
//                    key: [UInt8]? = nil,
//                    timeout: TimeInterval = 90,
//                    responseHandler: Response) {
//
//    guard let url = url else {
//        let error = NSError(domain: "invalid URL", code: 0, userInfo: nil)
//        #if DEBUG
//        print(error.localizedDescription)
//        #endif
//        responseHandler?(nil, false, nil, error)
//        return
//    }
//
//    let cachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalCacheData
//    var urlRequest = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeout)
//
//    // parameters
//    if parameters != nil {
//        switch method {
//        case .get:
//            var components = URLComponents(string: url.absoluteString)
//
//            var queryItems = [URLQueryItem]()
//            for (k, v) in parameters! {
//                let arr = (v as? Array<Any?>) ?? [v]
//                for item in arr {
//                    queryItems.append(URLQueryItem(name: k, value: "\(item ?? "")"))
//                }
//            }
//
//            if components?.queryItems == nil { components?.queryItems = [] }
//            components?.queryItems?.append(contentsOf: queryItems)
//            let requestURL = components?.url ?? url
//            urlRequest = URLRequest(url: requestURL, cachePolicy: cachePolicy, timeoutInterval: timeout)
//
//        case .post, .put:
//            if let parameters = parameters {
//                let contentType = headers?["Content-Type"]
//
//                if contentType == nil {
//                    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
//                }
//
//                if contentType == "application/json" || contentType == nil {
//                    do {
//                        if let key = key {
//                            let data = try JSONSerialization.data(withJSONObject: parameters)
//                            if let AES = try? AES (key: key, blockMode: ECB(), padding: .pkcs7) {
//                                let body = try AES.encrypt(data.bytes)
//                                urlRequest.httpBody = try? JSON(["data": body] as Any).rawData()
//                            }
//                        } else {
//                            urlRequest.httpBody = try? JSON(parameters as Any).rawData()
//                        }
//                    } catch {
//                        print(error.localizedDescription)
//                    }
//                }
//                else if contentType == "application/x-www-form-urlencoded" {
//                    let components = parameters.map { (k, v) -> String in
//                        return "\(k)=\(v ?? "")"
//                    }
//                    urlRequest.httpBody = components.joined(separator: "&").data(using: .utf8)
//                }
//                else {
//                    print(#function, "Unsupported Content-Type")
//                }
//            }
//        }
//    }
//
//    // headers
//    for (k, v) in headers ?? [:] {
//        urlRequest.setValue(v, forHTTPHeaderField: k)
//    }
//
//    //
//    urlRequest.httpMethod = method.rawValue
//
//    debugPrint("🔗🔗 urlRequest \(urlRequest)")
//
//    (URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
//        let response = (response as? HTTPURLResponse)
//        let statusCode = response?.statusCode ?? 500
//        let success = ( error == nil && (200..<400).contains(statusCode) )
//        DispatchQueue.main.async {
//            responseHandler?(data, success, response, error)
//        }
//    }).resume()
//}

//MARK: aesEncrypt
extension String {
    func aesEncrypt(key: String) throws -> [UInt8] {
        let iv = AES.randomIV(AES.blockSize)
        let encrypted = try AES(
            key: [UInt8](key.utf8),
            blockMode: CBC(iv: iv),
            padding: .pkcs7
        ).encrypt(
            [UInt8](self.utf8)
        )
        return iv + encrypted
    }
}
