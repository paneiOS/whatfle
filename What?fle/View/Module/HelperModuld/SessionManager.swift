//
//  SessionManager.swift
//  What?fle
//
//  Created by JeongHwan Lee on 9/7/24.
//

import Foundation

final class SessionManager {
    enum UserType {
        case member
        case guest
    }

    static let shared = SessionManager()
    private let keychainManager = KeychainManager.shared

    private init() {}

    var isLogin: Bool {
        guard let accessToken = keychainManager.loadAccessToken(for: .member) else { return false }
        return !accessToken.isEmpty
    }

    func login(token: String, for userType: UserType = .member, _ items: Any...) {
        switch userType {
        case .guest:
            keychainManager.delete(service: .accessToken)
        case .member:
            keychainManager.delete(service: .guestAccessToken)
        }
        keychainManager.saveAccessToken(token: token, for: userType)
        
        logPrint(items, token)
    }

    func logout(_ items: Any...) {
        keychainManager.delete(service: .accessToken)
        keychainManager.delete(service: .userInfo)
        logPrint(items.reversed())
    }

    func loadAccessToken(for userType: UserType = .member) -> String? {
        return keychainManager.loadAccessToken(for: userType)
    }

    func saveUserInfo(_ userInfo: UserInfo) {
        try? keychainManager.saveUserInfo(model: userInfo)
    }
}
