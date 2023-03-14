//
//  Purchase.swift
//  Purchase DEMO
//
//  Created by 🐳 on 2023/3/8.
//

import Foundation
import UIKit
import SwiftyStoreKit



class Purchase: NSObject {
    
    static let shared = Purchase()
    
    let loadingView = LoadingView()
    
    let uuid = UUID()
    
    
    /// 订阅过期日期，默认过期
    private var expireDate: Date {
        set {
            debugPrint("expireDate newValue: ", newValue)
            UserRecorder.vipExpireDate = newValue
        }
        get {
            return UserRecorder.vipExpireDate
        }
    }
    
    /// 订阅是否过期
    var isSubscribeExpired: Bool {
        let currentDate = Date()
        if expireDate.compare(currentDate) == .orderedAscending {
            return true
        } else {
            return false
        }
    }
    
    func getUUID() {
        let uuidString = uuid.uuidString
        print(uuidString)
    }
    
    
    // didFinishLaunchingWithOptions 调用,用于完成之前未完成的交易。如果你没有在应用程序启动时调用它，可能会导致交易未被正确处理，从而导致用户被多次收费或无法恢复购买等问题。
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
    
    //处理交易
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
                if let priceString = product.localizedPrice {//本地化价格字符串
                    let productID = product.productIdentifier
                    
                    //自定义折扣价格显示
                    //                let numberFormatter = NumberFormatter()
                    //                numberFormatter.locale = product.priceLocale
                    //                numberFormatter.numberStyle = .currency
                    //
                    if productID ==  K.vipYearID {
                        yearPrice = priceString
                    } else {
                        weekPrice = priceString
                    }
                    
                    logMesg.append(contentsOf: "Product: \(product.localizedDescription), price: \(priceString )\n")
                }
            }

            debugPrint(logMesg)
            
            
            if let invalidProductId = result.invalidProductIDs.first {
                debugPrint("无效的产品标识符: \(invalidProductId)")
            }
            
            if let error = result.error {
                debugPrint("获取价格失败：", error)
            }
                
            UserRecorder.setPrice(price: weekPrice, productID: K.vipWeekID)
            UserRecorder.setPrice(price: yearPrice, productID: K.vipYearID)
            complete?()
        }
    }
    
    //支付请求
    func purchaseProduct(_ productId: String, completion: @escaping ((Bool, String) -> Void)) {
        self.loadingView.show()
        SwiftyStoreKit.purchaseProduct(productId) { result in
            switch result {
            case .success(let purchase):
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
                
                self.getExpireDate(receipt: receipt, productId: K.vipWeekID)
                
                self.getExpireDate(receipt: receipt, productId: K.vipYearID)
                
                // 周订阅
//                let weekPurchaseResult = SwiftyStoreKit.verifySubscription(
//                    ofType: .autoRenewable,
//                    productId: K.vipWeekID,
//                    inReceipt: receipt
//                )
                
                
                
//                switch weekPurchaseResult {
//                case .purchased(let expiryDate, _):
//                    debugPrint("\(K.vipWeekID) 有效期至 \(expiryDate)\n")
//                    theExpiryDate = expiryDate
//
//                    self.handlePurchaseSuccess(productId: K.vipWeekID)
//                case .expired(let expiryDate, _):
//                    debugPrint("\(K.vipWeekID) 已过期 \n")
//                    theExpiryDate = expiryDate
//
//                case .notPurchased:
//                    break
//                }
//
//                // 年订阅
//                let yearPurchaseResult = SwiftyStoreKit.verifySubscription(
//                    ofType: .autoRenewable,
//                    productId: K.vipYearID,
//                    inReceipt: receipt
//                )
//                switch yearPurchaseResult {
//                case .purchased(let expiryDate, _):
//                    debugPrint("\(K.vipYearID) 有效期至 \(expiryDate)\n")
//                    theExpiryDate = expiryDate
//
//                    self.handlePurchaseSuccess(productId: K.vipYearID)
//                case .expired(let expiryDate, _):
//                    debugPrint("\(K.vipYearID) 已过期 \n")
//                    theExpiryDate = expiryDate
//
//                case .notPurchased:
//                    break
//                }
            
               

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
    
    func getExpireDate(receipt: ReceiptInfo, productId: String){
        var theExpiryDate = Date.distantPast
        
        let purchaseResult = SwiftyStoreKit.verifySubscription(
            ofType: .autoRenewable,
            productId: productId,
            inReceipt: receipt
        )
        switch purchaseResult {
        case .purchased(let expiryDate, _):
            debugPrint("\(productId) 有效期至 \(expiryDate)\n")
            //记录订阅过期时间
            self.expireDate = theExpiryDate

            self.handlePurchaseSuccess(productId: productId)
        case .expired(let expiryDate, _):
            debugPrint("\(productId) 已过期 \n")
            //记录订阅过期时间
            self.expireDate = theExpiryDate
      
        case .notPurchased:
            break
        }
    }
    
    //内购购买成功
    func handlePurchaseSuccess(productId: String) {
        if productId == K.vipYearID {
            UserRecorder.setPurchased(purchase: true, productID: K.vipYearID)
            UserRecorder.setPurchased(purchase: false, productID: K.vipWeekID)
        } else if productId == K.vipWeekID {
            UserRecorder.setPurchased(purchase: false, productID: K.vipYearID)
            UserRecorder.setPurchased(purchase: true, productID: K.vipWeekID)
        }
    }
    
    //恢复购买
    func restorePurchases(completion: @escaping ((Bool) -> Void)) {
        fetchReceipt { (success, _) in completion(success) }
    }
    
    //获取账单
    private func fetchReceipt(forceRefresh: Bool = true, completion: @escaping ((Bool, String?)->Void)) {
        SwiftyStoreKit.fetchReceipt(forceRefresh: forceRefresh) { result in
            switch result {
            case .success:
                self.verifySubscription {
                    completion(!self.isSubscribeExpired, nil)
                }
            case .error(let error):
                completion(false, error.localizedDescription)
                debugPrint("Fetch receipt failed: \(error)")
            }
        }
    }
  
    
}

