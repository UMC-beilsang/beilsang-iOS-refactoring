//
//  KeychainTokenStorageProtocol.swift
//  CoreStorage
//
//  Created by Seyoung Park on 8/31/25.
//

import Foundation
import ModelsShared

public protocol KeychainTokenStorageProtocol {
    func saveToken(_ token: KeychainToken) async throws
    func getToken() async throws -> KeychainToken?
    func deleteToken() async throws
}
