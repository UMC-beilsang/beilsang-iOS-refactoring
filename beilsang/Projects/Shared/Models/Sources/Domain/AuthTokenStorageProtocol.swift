//
//  AuthTokenStorageProtocol.swift
//  ModelsShared
//
//  Created by Seyoung Park on 8/31/25.
//

import Foundation
import Combine

public protocol AuthTokenStorageProtocol {
    func saveToken(_ token: AuthToken) -> AnyPublisher<Void, AuthError>
    func getToken() -> AnyPublisher<AuthToken?, Never>
    func deleteToken() -> AnyPublisher<Void, Never>
}
