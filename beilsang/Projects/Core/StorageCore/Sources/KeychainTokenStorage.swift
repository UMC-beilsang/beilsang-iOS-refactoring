//
//  KeychainTokenStorage.swift
//  CoreStorage
//
//  Created by Seyoung Park on 8/31/25.
//

import Foundation
import Security
import ModelsShared

public final class KeychainTokenStorage: KeychainTokenStorageProtocol {
    private let service = "com.beilsang.auth"
    private let account = "authToken"

    public init() {}

    public func saveToken(_ token: KeychainToken) async throws {
        let data = try JSONEncoder().encode(token)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)

        let attributes: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        let status = SecItemAdd(attributes as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.keychainSaveFailed(status)
        }
    }

    public func getToken() async throws -> KeychainToken? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataRef)

        if status == errSecSuccess, let data = dataRef as? Data {
            return try JSONDecoder().decode(KeychainToken.self, from: data)
        } else if status == errSecItemNotFound {
            return nil
        } else {
            throw KeychainError.keychainLoadFailed(status)
        }
    }

    public func deleteToken() async throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.keychainDeleteFailed(status)
        }
    }
}
