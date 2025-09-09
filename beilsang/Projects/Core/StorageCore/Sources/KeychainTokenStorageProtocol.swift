//
//  KeychainTokenStorageProtocol.swift
//  CoreStorage
//
//  Created by Seyoung Park on 8/31/25.
//

import Foundation
import Combine
import ModelsShared

public protocol KeychainTokenStorageProtocol {
    func saveToken(_ token: KeychainToken) -> AnyPublisher<Void, KeychainError>
    func getToken() -> AnyPublisher<KeychainToken?, KeychainError>
    func deleteToken() -> AnyPublisher<Void, KeychainError>
}
