//
//  AppleLoginModels.swift
//  ModelsShared
//
//  Created by Seyoung Park on 8/31/25.
//

import Foundation

// MARK: - Request
public struct AppleLoginRequest: Codable, Sendable {
    public let identityToken: String
    
    public init(idToken: String) {
        self.identityToken = idToken
    }
}

// MARK: - Response
public typealias AppleLoginResponse = APIResponse<AppleLoginResult>

public struct AppleLoginResult: Codable, Sendable {
    public let accessToken: String
    public let refreshToken: String
    public let isExistMember: Bool
}
