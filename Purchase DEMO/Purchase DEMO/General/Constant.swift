//
//  Constant.swift
//  Purchase DEMO
//
//  Created by 🐳 on 2023/3/8.
//

import Foundation

struct K {
    static let MMKVID = "PurchaseMMKVID"
    
    static let vipWeekID = "com.air.share.weekly"
    static let vipYearID = "com.air.share.yearly"
    static let vipSecret = "412e7ac9a6ce43438a4c3192764a267a"
    
    
    struct Path {
        static var document: URL {
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            return url
        }
    }
}
