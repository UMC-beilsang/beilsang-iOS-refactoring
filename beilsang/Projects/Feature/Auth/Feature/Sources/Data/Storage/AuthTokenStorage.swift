//
//  AuthTokenStorage.swift
//  AuthFeature
//
//  Created by Park Seyoung on 8/28/25.
//

import Foundation
import Combine
import Security
import ModelsShared

final class AuthTokenStorage: AuthTokenStorageProtocol {
    private let tokenKey = "beilsang.auth.token"
    
    func saveToken(_ token: AuthToken) -> AnyPublisher<Void, AuthError> {
        Future<Void, AuthError> { promise in
            do {
                let data = try JSONEncoder().encode(token)
                let status = self.saveToKeychain(data: data, key: self.tokenKey)
                if status == errSecSuccess {
                    promise(.success(()))
                } else {
                    promise(.failure(.unknownError("Failed to save token to keychain: \(status)")))
                }
            } catch {
                promise(.failure(.unknownError("Failed to encode token: \(error.localizedDescription)")))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getToken() -> AnyPublisher<AuthToken?, Never> {
        Future<AuthToken?, Never> { promise in
            guard let data = self.loadFromKeychain(key: self.tokenKey) else {
                promise(.success(nil))
                return
            }
            do {
                let token = try JSONDecoder().decode(AuthToken.self, from: data)
                promise(.success(token))
            } catch {
                promise(.success(nil))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func deleteToken() -> AnyPublisher<Void, AuthError> {
        Future<Void, AuthError> { promise in
            let status = self.deleteFromKeychain(key: self.tokenKey)
            if status == errSecSuccess || status == errSecItemNotFound {
                promise(.success(()))
            } else {
                promise(.failure(.unknownError("Failed to delete token from keychain: \(status)")))
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Private Keychain Methods
    private func saveToKeychain(data: Data, key: String) -> OSStatus {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary) // 기존 삭제
        return SecItemAdd(query as CFDictionary, nil)
    }
    
    private func loadFromKeychain(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        if status == errSecSuccess {
            return dataTypeRef as? Data
        }
        return nil
    }
    
    private func deleteFromKeychain(key: String) -> OSStatus {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        return SecItemDelete(query as CFDictionary)
    }
}
