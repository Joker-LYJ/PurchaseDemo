//
//  NetworkMannager.swift
//  Purchase DEMO
//
//  Created by 🐳 on 2023/3/10.
//

import Foundation
import Alamofire
import Network

class NetworkMannager: NSObject {
    
    static let shared = NetworkMannager()
    
    let noConnectionView = NoConnectionView()
    
    //网络权限 备用方法
    func requestNetworkPermission(completion: @escaping (Bool) -> Void) {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "Network")
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                completion(true) // 网络可用
            } else {
                completion(false) // 网络不可用
            }
        }
    }
    
    func setNetWorkObserver() {
        //AF监听网络状态
        NetworkReachabilityManager.default?.startListening(onUpdatePerforming: { status in
            switch status {
            case .reachable(_):
                self.noConnectionView.hide()
                break
            case .notReachable:
                self.noConnectionView.show()
                break
            default:
                break
            }
        })
    }
    
}
