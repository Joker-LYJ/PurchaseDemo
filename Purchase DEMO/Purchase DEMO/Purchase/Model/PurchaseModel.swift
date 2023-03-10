//
//  PurchaseModel.swift
//  Purchase DEMO
//
//  Created by 🐳 on 2023/3/9.
//

import Foundation

enum PurchaseType: String {
    case week
    case year
    case no
    
    
}

class PurchaseModel: NSObject, Codable {
    var weekPrice: String?
    var yearPrice: String?
    var purchasedStatus: String?
   
    init(weekPrice: String?, yearPrice: String?, purchasedStatus: String? = nil) {
        self.weekPrice = weekPrice
        self.yearPrice = yearPrice
        self.purchasedStatus = purchasedStatus
    }
}
