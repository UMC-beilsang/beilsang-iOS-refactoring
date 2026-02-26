//
//  KeychainToken.swift
//  ModelsShared
//
//  Created by Seyoung Park on 8/31/25.
//

import Foundation

public enum SocialProvider: String, Codable, Sendable {
    case kakao
    case apple
}

public struct KeychainToken: Codable, Equatable, Sendable {
    public let accessToken: String
    public let refreshToken: String
    public let tokenType: String
    public let expiresIn: TimeInterval
    public let createdAt: Date
    public let provider: SocialProvider?
    
    public init(
        accessToken: String,
        refreshToken: String,
        tokenType: String = "Bearer",
        expiresIn: TimeInterval = 0,
        createdAt: Date = Date(),
        provider: SocialProvider? = nil
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.tokenType = tokenType
        self.expiresIn = expiresIn
        self.createdAt = createdAt
        self.provider = provider
    }
    
    // 토큰 만료 여부 체크
    public var isExpired: Bool {
        guard expiresIn > 0 else { return false } // 0이면 만료 개념 없음
        return Date().timeIntervalSince(createdAt) >= expiresIn
    }
}
