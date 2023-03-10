//
//  NetworkMannager.swift
//  Purchase DEMO
//
//  Created by ð³ on 2023/3/10.
//

import Foundation
import Alamofire
import Network

class NetworkMannager: NSObject {
    
    static let shared = NetworkMannager()
    
    let noConnectionView = NoConnectionView()
    
    //ç½ç»æé å¤ç¨æ¹æ³
    func requestNetworkPermission(completion: @escaping (Bool) -> Void) {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "Network")
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                completion(true) // ç½ç»å¯ç¨
            } else {
                completion(false) // ç½ç»ä¸å¯ç¨
            }
        }
    }
    
    func setNetWorkObserver() {
        //AFçå¬ç½ç»ç¶æ
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
