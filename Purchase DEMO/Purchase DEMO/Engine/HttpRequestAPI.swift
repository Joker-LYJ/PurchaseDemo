//
//  HttpRequestAPI.swift
//  Purchase DEMO
//
//  Created by 🐳 on 2023/3/13.
//

import Foundation

enum HttpRequestAPI {
    case create
    case startUp
    case chat
    case verify
    case faq
    case chatImg
    
    var api: String {
        switch self {
        case .create:
            return "/api/user/create"
        case .startUp:
            return "/api/user/startup"
        case .faq:
            return "/api/open-ai/faq"
        case .chat:
            return "/api/open-ai/chat"
        case .verify:
            return "/api/order/verify"
        case .chatImg:
            return "/api/txt2img/chat"
        }
    }
    
    func url(querys: HttpParameters? = nil) -> String {
        var query: String = ""
        // query
        if let querys = querys {
            let components = querys.map { (k, v) -> String in
                return "\(k)=\(v ?? "")"
            }
            query = "?" + components.joined(separator: "&")
        }
        return api + query
    }
}
