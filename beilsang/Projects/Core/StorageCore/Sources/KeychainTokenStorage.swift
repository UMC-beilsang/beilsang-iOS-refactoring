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

                // 기존 값 삭제
                let query: [String: Any] = [
                    kSecClass as String: kSecClassGenericPassword,
                    kSecAttrService as String: self.service,
                    kSecAttrAccount as String: self.account
                ]
                SecItemDelete(query as CFDictionary)

                // 새 값 저장
                let attributes: [String: Any] = [
                    kSecClass as String: kSecClassGenericPassword,
                    kSecAttrService as String: self.service,
                    kSecAttrAccount as String: self.account,
                    kSecValueData as String: data
                ]
                let status = SecItemAdd(attributes as CFDictionary, nil)

                if status == errSecSuccess {
                    promise(.success(()))
                } else {
                    promise(.failure(.keychainSaveFailed(status)))
                }
            } catch {
                promise(.failure(.encodingFailed(error.localizedDescription)))
            }
        }
        .eraseToAnyPublisher()
    }

    public func getToken() -> AnyPublisher<KeychainToken?, KeychainError> {
        Future { promise in
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
                    promise(.success(token))
                } catch {
                    promise(.failure(.decodingFailed(error.localizedDescription)))
                }
            } else if status == errSecItemNotFound {
                promise(.success(nil)) // 토큰 없으면 nil
            } else {
                promise(.failure(.keychainLoadFailed(status)))
            }
        }
        .eraseToAnyPublisher()
    }

    public func deleteToken() -> AnyPublisher<Void, KeychainError> {
        Future { promise in
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: self.service,
                kSecAttrAccount as String: self.account
            ]
            let status = SecItemDelete(query as CFDictionary)
            if status == errSecSuccess || status == errSecItemNotFound {
                promise(.success(()))
            } else {
                promise(.failure(.keychainDeleteFailed(status)))
            }
        }
        .eraseToAnyPublisher()
    }
}
