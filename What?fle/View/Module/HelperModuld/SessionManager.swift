//
//  SessionManager.swift
//  What?fle
//
//  Created by JeongHwan Lee on 9/7/24.
//

import Foundation

final class SessionManager {
    static let shared = SessionManager()
    private let keychainManager = KeychainManager.shared

    private init() {}

    var isLoggedIn: Bool {
        guard let accessToken = keychainManager.loadAccessToken() else { return false }
        return !accessToken.isEmpty
    }

//    var isSignedIn: Bool {
//        guard let userInfo: UserInfo = try? keychainManager.loadUserInfo() else { return false }
//        return userInfo.isAgreement
//    }

    func login(token: String, _ items: Any...) {
        keychainManager.saveAccessToken(token: token)
        logPrint(items, token)
    }

    func logout(_ items: Any...) {
        keychainManager.deleteAccessToken()
        logPrint(items.reversed())
    }

    func saveUserInfo(_ userInfo: UserInfo) {
        try? keychainManager.saveUserInfo(model: userInfo)
    }
}
