//
//  AuthTokenStorage.swift
//  ModelsShared
//
//  Created by Seyoung Park on 8/31/25.
//

import Foundation
import Security
import Combine
import ModelsShared

final class AuthTokenStorage: AuthTokenStorageProtocol {
    private let service = "com.beilsang.auth"
    private let account = "authToken"

    func saveToken(_ token: AuthToken) -> AnyPublisher<Void, AuthError> {
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
                    promise(.failure(.networkError)) // 여기서는 AuthError 재사용
                }
            } catch {
                promise(.failure(.unknownError("Token encoding failed")))
            }
        }
        .eraseToAnyPublisher()
    }

    func getToken() -> AnyPublisher<AuthToken?, Never> {
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
                let token = try? JSONDecoder().decode(AuthToken.self, from: data)
                promise(.success(token))
            } else {
                promise(.success(nil)) // 토큰이 없을 수도 있으니 nil 반환
            }
        }
        .eraseToAnyPublisher()
    }

    func deleteToken() -> AnyPublisher<Void, Never> {
        Future { promise in
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: self.service,
                kSecAttrAccount as String: self.account
            ]
            SecItemDelete(query as CFDictionary)
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }
}
