//
//  AppDelegate.swift
//  Purchase DEMO
//
//  Created by 🐳 on 2023/3/8.
//

import UIKit
import Alamofire
import MMKV

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = BaseNavigationController(rootViewController: HomePageViewController())
        window?.makeKeyAndVisible()
        
        //用于完成之前未完成的交易。如果你没有在应用程序启动时调用它，可能会导致交易未被正确处理，从而导致用户被多次收费或无法恢复购买等问题。
        Purchase.shared.completeTransactions()
        //网络监听
//        Purchase.shared.setNetWorkObserver()
        
        // 在主线程中初始化MMKV
        DispatchQueue.main.async {
            MMKV.initialize(rootDir: nil)
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
            Purchase.shared.getPrices()
            Purchase.shared.verifySubscription{}
        }
        
        return true
    }



}

