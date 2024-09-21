//
//  KeychainManager.swift
//  What?fle
//
//  Created by JeongHwan Lee on 8/16/24.
//

import Foundation
import Security

final class KeychainManager {
    static let shared = KeychainManager()
    private init() {}

    enum Service: String {
        case userInfo
        case accessToken
        case guestAccessToken

        func identifier() -> String {
            return "com.Whatfle.What." + self.rawValue
        }
    }

    private enum KeychainError: Error {
        case saveError(status: OSStatus)
        case deleteError(status: OSStatus)
        case encodingError(Error)
    }

    private func save(service: String, data: Data) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecValueData as String: data
        ]

        let deleteStatus = SecItemDelete(query as CFDictionary)
        if deleteStatus != errSecSuccess && deleteStatus != errSecItemNotFound {
            return
        }

        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            return
        }
    }

    private func load(service: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecReturnData as String: kCFBooleanTrue as Any,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess else { return nil }
        return item as? Data
    }

    func delete(service: Service) {
        self.delete(service: service.identifier())
    }
    
    @discardableResult
    private func delete(service: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }

    func saveUserInfo(model: UserInfo) throws {
        do {
            let data = try JSONEncoder().encode(model)
            save(service: Service.userInfo.identifier(), data: data)
        } catch {
            throw handleKeychainError(error)
        }
    }

    func loadUserInfo() throws -> UserInfo? {
        do {
            guard let data = load(service: Service.userInfo.identifier()) else { return nil }
            return try JSONDecoder().decode(UserInfo.self, from: data)
        } catch {
            throw handleKeychainError(error)
        }
    }

    func saveAccessToken(token: String, for userType: SessionManager.UserType) {
        guard let accessToken = token.data(using: .utf8) else { return }
        let service = userType == .member ? Service.accessToken.identifier() : Service.guestAccessToken.identifier()
        save(service: service, data: accessToken)
    }

    func loadAccessToken(for userType: SessionManager.UserType) -> String? {
        let service = userType == .member ? Service.accessToken.identifier() : Service.guestAccessToken.identifier()
        guard let data = load(service: service) else { return nil }
        return String(data: data, encoding: .utf8) ?? nil
    }

    private func handleKeychainError(_ error: Error) -> KeychainError {
        if let keychainError = error as? KeychainError {
            return keychainError
        } else if let encodingError = error as? EncodingError {
            return .encodingError(encodingError)
        } else {
            return .saveError(status: -1)
        }
    }
}
