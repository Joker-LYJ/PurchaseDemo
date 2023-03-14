//
//  User.swift
//  Purchase DEMO
//
//  Created by 🐳 on 2023/3/13.
//

import Foundation
import Combine

class User: NSObject, Subscriber {

    typealias Input = User
    typealias Failure = Never

    var userId: String? {
        set {
            UserRecorder.userID = newValue
        }
        get {
            UserRecorder.userID?.isEmpty == true ? nil : UserRecorder.userID
        }
    }

    static let shared = User()

    @available(iOS 13.0, *)
    func receive(subscription: Subscription) {

    }

    @available(iOS 13.0, *)
    func receive(_ input: User) -> Subscribers.Demand {
        return .none
    }

    @available(iOS 13.0, *)
    func receive(completion: Subscribers.Completion<Never>) {

    }
}
