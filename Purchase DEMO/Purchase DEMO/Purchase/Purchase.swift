//
//  Purchase.swift
//  Purchase DEMO
//
//  Created by 🐳 on 2023/3/8.
//

import Foundation
import UIKit
import SwiftyStoreKit
import Network
import Alamofire

class Purchase: NSObject {
    
    static let shared = Purchase()
    
    let noConnetionView = NoConnectionView()
    
    let loadingView = LoadingView()
    
    var model = PurchaseModel.init(weekPrice: nil, yearPrice: nil)
    
    // didFinishLaunchingWithOptions 调用
    func completeTransactions() {
        SwiftyStoreKit.completeTransactions() { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    self.handleTransaction(purchase.transaction) { _, _ in }
                case .failed, .purchasing, .deferred:
                    break
                }
            }
        }
    }
    
    func handleTransaction(_ transaction: PaymentTransaction?, completion: @escaping (Bool, String?) -> Void) {
        print(#function)
        SwiftyStoreKit.fetchReceipt(forceRefresh: true) { result in
            switch result {
            case .success(_):
                if let transaction = transaction {SwiftyStoreKit.finishTransaction(transaction)
                }
                completion(true, nil)
            case .error(let error):
                debugPrint("Fetch receipt failed: \(error)")
                completion(false, error.localizedDescription)

            }
        }
    }
    
 
    
    /// 订阅过期日期，默认过期
    var expireDate: Date {
        set {
            debugPrint("expireDate newValue: ", newValue)
            Recoder.vipExpireDate = newValue
        }
        get {
            return Recoder.vipExpireDate
        }
    }
    
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
                self.removeNoConnectinView()
            case .notReachable:
                self.showNoConnectionView()
            default:
                break
            }
        })
    }
    
    //展示无网络状态视图
    func showNoConnectionView() {
        noConnetionView.show()
    }
    
    //移除无网络状态视图
    func removeNoConnectinView() {
        noConnetionView.hide()
    }
    
    //获取价格
    func getPrices(complete:(()->Void)? = nil)  {
        let productIDs: Set<String> = [
            K.vipWeekID,
            K.vipYearID
        ]
        
        //本地价格
        var yearPrice = "本地价100块"
        var weekPrice = "本地价50块"
        
        SwiftyStoreKit.retrieveProductsInfo(productIDs) { (result) in
            var logMesg = ""
            for product in result.retrievedProducts {
                let priceString = product.localizedPrice //本地化价格字符串
                let productID = product.productIdentifier
                
                //自定义价格显示
//                let numberFormatter = NumberFormatter()
//                numberFormatter.locale = product.priceLocale
//                numberFormatter.numberStyle = .currency
//
                if let price = priceString {
                    if productID ==  K.vipYearID {
                        yearPrice = price
    //                    UserRecord.setPrimeCostPrice(price: numberFormatter.string(from: NSNumber(value: product.price.floatValue / 0.5)) ?? "", productID: productID)
                    } else {
                        weekPrice = price
                    }
                }

                logMesg.append(contentsOf: "Product: \(product.localizedDescription), price: \(priceString ?? "")\n")
            }
//            
//            NotificationCenter.default.post(name: NotificationName.purchasePriceDidChange, object: nil)
            debugPrint(logMesg)
            
            
            
            
            self.model.weekPrice = weekPrice
            self.model.yearPrice = yearPrice
            self.updateRecorderData()
            
            
            if let invalidProductId = result.invalidProductIDs.first {
                debugPrint("无效的产品标识符: \(invalidProductId)")
            }
            
            if let error = result.error {
                debugPrint("获取价格失败：", error)
//                showToast(text: __("网络连接超时，请检查网络"))
            }
            
            complete?()
        }
    }
    
    //支付请求
    func purchaseProduct(_ productId: String, completion: @escaping ((Bool, String) -> Void)) {
        self.loadingView.show()
        SwiftyStoreKit.purchaseProduct(productId) { result in
            switch result {
            case .success(let purchase):
                debugPrint("Purchase Success", purchase.productId)

                if purchase.productId == K.vipYearID ||
                    purchase.productId == K.vipWeekID
                {
                    self.verifySubscription {
                        self.handlePurchaseSuccess(productId: purchase.productId)
                        self.loadingView.hide()
                        completion(true, "")
                    }
                } else {
                    self.loadingView.hide()
                    completion(true, "")
                }
            case .error(let error):
                debugPrint("购买失败", error.localizedDescription)
                self.loadingView.hide()
                completion(false, error.localizedDescription)
                
            }
            
        }
    }
    
    /// 验证、处理订阅结果订阅
    func verifySubscription(completion: @escaping () -> Void) {
        #if DEBUG
        let service = AppleReceiptValidator.VerifyReceiptURLType.sandbox
        #else
        let service = AppleReceiptValidator.VerifyReceiptURLType.production
        #endif
        let appleValidator = AppleReceiptValidator(service: service, sharedSecret: K.vipSecret)

        SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: true) {  (result) in
            switch result {
            case .success(let receipt):
                var theExpiryDate = Date.distantPast
             
                // 周订阅
                let weekPurchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable,
                    productId: K.vipWeekID,
                    inReceipt: receipt
                )
                switch weekPurchaseResult {
                case .purchased(let expiryDate, _):
                    debugPrint("\(K.vipWeekID) is valid until \(expiryDate)\n")
                    theExpiryDate = expiryDate
                 
                    self.handlePurchaseSuccess(productId: K.vipWeekID)
                case .expired(let expiryDate, _):
                    debugPrint("\(K.vipWeekID) is expire \n")
                    theExpiryDate = expiryDate
              
                case .notPurchased:
                    break
                }
                
                // 年订阅
                let yearPurchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable,
                    productId: K.vipYearID,
                    inReceipt: receipt
                )
                switch yearPurchaseResult {
                case .purchased(let expiryDate, _):
                    debugPrint("\(K.vipYearID) is valid until \(expiryDate)\n")
                    theExpiryDate = expiryDate
                 
                    self.handlePurchaseSuccess(productId: K.vipYearID)
                case .expired(let expiryDate, _):
                    debugPrint("\(K.vipYearID) is expire \n")
                    theExpiryDate = expiryDate
                    
                case .notPurchased:
                    break
                }
            
                
                self.expireDate = theExpiryDate
//                Poster_CustomLibraryDemo_.shared.enabled = adEnabled
//                NotificationCenter.default.post(name: NotificationName.purchaseDidChange, object: nil)
                
                debugPrint(
                    """
                    当前时间: \(Date().description(with: Locale.current))
                    订阅过期时间: \(self.expireDate.description(with: Locale.current))
                    """
                )
            case .error(let error):
                debugPrint("Verify receipt failed: \(error)")
            }
            completion()
        }
    }
    
    /// 内购购买成功
    func handlePurchaseSuccess(productId: String) {
        if productId == K.vipYearID {
            self.model.purchasedStatus =  "year"
////            UserRecord.setPurchased(purchase: true, productID: PurchaseID.vipYear)
////            UserRecord.setPurchased(purchase: false, productID: PurchaseID.vipMonth)
////            UserRecord.setPurchased(purchase: false, productID: PurchaseID.lifetime)
        } else if productId == K.vipWeekID {
            self.model.purchasedStatus =  "week"
////            UserRecord.setPurchased(purchase: false, productID: PurchaseID.vipYear)
////            UserRecord.setPurchased(purchase: true, productID: PurchaseID.vipMonth)
        } else {
            self.model.purchasedStatus =  "no"
        }
        updateRecorderData()
    }
    
    func updateRecorderData() {
        Recoder.PurchaseInfomation = self.model
    }
    
}

