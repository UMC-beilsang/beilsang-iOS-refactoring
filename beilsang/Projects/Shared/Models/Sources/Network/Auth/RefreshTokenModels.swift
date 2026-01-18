//
//  RefreshTokenModels.swift
//  ModelsShared
//
//  Created by Seyoung Park on 8/31/25.
//

import Foundation

// MARK: - Request
public struct RefreshTokenRequest: Codable, Sendable {
    public let refreshToken: String
    
    public init(refreshToken: String) {
        self.refreshToken = refreshToken
    }
    
    public init(from token: String) {
        self.refreshToken = token
    }
}

// MARK: - Response
/// 서버 응답: APIResponse 형태로 statusCode, code, message, data 필드 사용
public typealias RefreshTokenResponse = APIResponse<RefreshTokenData>

public struct RefreshTokenData: Codable, Sendable {
    public let accessToken: String
    public let refreshToken: String
    public let isExistMember: Bool?
    
    public init(accessToken: String, refreshToken: String, isExistMember: Bool? = nil) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.isExistMember = isExistMember
    }
}
