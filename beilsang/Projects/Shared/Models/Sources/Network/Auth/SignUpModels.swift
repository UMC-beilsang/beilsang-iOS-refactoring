//
//  SignUpModels.swift
//  ModelsShared
//
//  Created by Seyoung Park on 8/31/25.
//

import Foundation

// MARK: - Request
public struct SignUpRequest: Codable, Sendable {
    public let accessToken: String
    public let gender: String
    public let nickName: String
    public let birth: String
    public let address: String
    public let keyword: String
    public let discoveredPath: String
    public let resolution: String
    public let recommendNickname: String
    
    public init(
        accessToken: String,
        gender: String,
        nickName: String,
        birth: String,
        address: String,
        keyword: String,
        discoveredPath: String,
        resolution: String,
        recommendNickname: String
    ) {
        self.accessToken = accessToken
        self.gender = gender
        self.nickName = nickName
        self.birth = birth
        self.address = address
        self.keyword = keyword
        self.discoveredPath = discoveredPath
        self.resolution = resolution
        self.recommendNickname = recommendNickname
    }
}

// MARK: - Response
public struct SignUpResponse: Codable, Sendable {
    public let code: String
    public let message: String
    public let data: EmptyData
    public let success: Bool
}

/// 서버 응답 data가 빈 객체 `{}` 인 경우
public struct EmptyData: Codable, Sendable {}
