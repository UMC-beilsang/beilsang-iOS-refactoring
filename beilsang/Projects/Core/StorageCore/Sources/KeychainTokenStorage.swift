//
//  KeychainTokenStorage.swift
//  CoreStorage
//
//  Created by Seyoung Park on 8/31/25.
//

import Foundation
import Security
import Combine
import ModelsShared

public final class KeychainTokenStorage: KeychainTokenStorageProtocol {
    private let service = "com.beilsang.auth"
    private let account = "authToken"

    public init() {}

    public func saveToken(_ token: KeychainToken) -> AnyPublisher<Void, KeychainError> {
        Future { promise in
            do {
                let data = try JSONEncoder().encode(token)

                #if DEBUG
                print("💾 Saving token to keychain...")
                print("   accessToken: \(token.accessToken.prefix(20))...")
                print("   refreshToken: \(token.refreshToken.prefix(20))...")
                #endif

                // 기존 값 삭제
                let query: [String: Any] = [
                    kSecClass as String: kSecClassGenericPassword,
                    kSecAttrService as String: self.service,
                    kSecAttrAccount as String: self.account
                ]
                let deleteStatus = SecItemDelete(query as CFDictionary)
                #if DEBUG
                if deleteStatus != errSecSuccess && deleteStatus != errSecItemNotFound {
                    print("⚠️ Failed to delete existing token: \(deleteStatus)")
                }
                #endif

                // 새 값 저장
                let attributes: [String: Any] = [
                    kSecClass as String: kSecClassGenericPassword,
                    kSecAttrService as String: self.service,
                    kSecAttrAccount as String: self.account,
                    kSecValueData as String: data
                ]
                let status = SecItemAdd(attributes as CFDictionary, nil)

                if status == errSecSuccess {
                    #if DEBUG
                    print("✅ Token saved to keychain successfully")
                    #endif
                    promise(.success(()))
                } else {
                    #if DEBUG
                    print("❌ Failed to save token to keychain: status=\(status)")
                    #endif
                    promise(.failure(.keychainSaveFailed(status)))
                }
            } catch {
                #if DEBUG
                print("❌ Failed to encode token: \(error)")
                #endif
                promise(.failure(.encodingFailed(error.localizedDescription)))
            }
        }
        .eraseToAnyPublisher()
    }

    public func getToken() -> AnyPublisher<KeychainToken?, KeychainError> {
        Future { promise in
            #if DEBUG
            print("🔍 Getting token from keychain...")
            #endif
            
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: self.service,
                kSecAttrAccount as String: self.account,
                kSecReturnData as String: true,
                kSecMatchLimit as String: kSecMatchLimitOne
            ]

            var dataRef: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &dataRef)

            if status == errSecSuccess, let data = dataRef as? Data {
                do {
                    let token = try JSONDecoder().decode(KeychainToken.self, from: data)
                    #if DEBUG
                    print("✅ Token found in keychain")
                    print("   accessToken: \(token.accessToken.prefix(20))...")
                    print("   refreshToken: \(token.refreshToken.prefix(20))...")
                    #endif
                    promise(.success(token))
                } catch {
                    #if DEBUG
                    print("❌ Failed to decode token: \(error)")
                    #endif
                    promise(.failure(.decodingFailed(error.localizedDescription)))
                }
            } else if status == errSecItemNotFound {
                #if DEBUG
                print("⚠️ No token found in keychain (errSecItemNotFound)")
                #endif
                promise(.success(nil)) // 토큰 없으면 nil
            } else {
                #if DEBUG
                print("❌ Failed to get token from keychain: status=\(status)")
                #endif
                promise(.failure(.keychainLoadFailed(status)))
            }
        }
        .eraseToAnyPublisher()
    }

    public func deleteToken() -> AnyPublisher<Void, KeychainError> {
        Future { promise in
            #if DEBUG
            print("🗑️ Deleting token from keychain...")
            #endif
            
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: self.service,
                kSecAttrAccount as String: self.account
            ]
            let status = SecItemDelete(query as CFDictionary)
            if status == errSecSuccess || status == errSecItemNotFound {
                #if DEBUG
                print("✅ Token deleted from keychain successfully")
                #endif
                promise(.success(()))
            } else {
                #if DEBUG
                print("❌ Failed to delete token from keychain: status=\(status)")
                #endif
                promise(.failure(.keychainDeleteFailed(status)))
            }
        }
        .eraseToAnyPublisher()
    }
}
