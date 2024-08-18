//
//  KeychainManager.swift
//  What?fle
//
//  Created by JeongHwan Lee on 8/16/24.
//

import Foundation
import Security

final class KeychainManager {
    private static let shared = KeychainManager()
    private init() {}

    private enum Service: String {
        case loginRequest
        case accessToken

        func identifier() -> String {
            return "com.Whatfle.What." + self.rawValue
        }
    }

    private enum KeychainError: Error {
        case saveError(status: OSStatus)
        case deleteError(status: OSStatus)
        case encodingError(Error)
    }

    private func save(service: String, data: Data) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecValueData as String: data
        ]

        let deleteStatus = SecItemDelete(query as CFDictionary)
        if deleteStatus != errSecSuccess && deleteStatus != errSecItemNotFound {
            throw KeychainError.deleteError(status: deleteStatus)
        }

        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            throw KeychainError.saveError(status: status)
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

    @discardableResult
    private func delete(service: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }

    static func saveUserInfo(model: UserInfo) throws {
        do {
            let data = try JSONEncoder().encode(model)
            let service = Service.loginRequest.identifier()
            try KeychainManager.shared.save(service: service, data: data)
        } catch {
            throw handleKeychainError(error)
        }
    }

    static func saveAccessToken(token: String) throws {
        guard let accessToken = token.data(using: .utf8) else {
            throw KeychainError.encodingError(NSError(domain: "InvalidString", code: -1, userInfo: nil))
        }
        let service = Service.accessToken.identifier()
        try KeychainManager.shared.save(service: service, data: accessToken)
    }

    static func loadAccessToken() -> String {
        let service = Service.loginRequest.identifier()
        guard let data = KeychainManager.shared.load(service: service) else {
            return ""
        }
        return String(data: data, encoding: .utf8) ?? ""
    }

    private static func handleKeychainError(_ error: Error) -> KeychainError {
        if let keychainError = error as? KeychainError {
            return keychainError
        } else if let encodingError = error as? EncodingError {
            return .encodingError(encodingError)
        } else {
            return .saveError(status: -1)
        }
    }
}
