//
//  AppleLoginModels.swift
//  ModelsShared
//
//  Created by Seyoung Park on 8/31/25.
//

import Foundation

// MARK: - Request
public struct AppleLoginRequest: Codable, Sendable {
    public let idToken: String
    public let deviceToken: String
    
    public init(idToken: String, deviceToken: String) {
        self.idToken = idToken
        self.deviceToken = deviceToken
    }
}

// MARK: - Response
public struct AppleLoginResponse: Codable, Sendable {
    public let code: String
    public let message: String
    public let data: AppleLoginData
    public let success: Bool
}

public struct AppleLoginData: Codable, Sendable {
    public let accessToken: String
    public let refreshToken: String
    public let clientSecret: String
    public let existMember: Bool
}
