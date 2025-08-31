//
//  KakaoLoginModels.swift
//  ModelsShared
//
//  Created by Seyoung Park on 8/31/25.
//

import Foundation

// MARK: - Request
public struct KakaoLoginRequest: Codable, Sendable {
    // TODO: 오타 수정
    public let accesstoken: String
    public let deviceToken: String

    public init(accesstoken: String, deviceToken: String) {
        self.accesstoken = accesstoken
        self.deviceToken = deviceToken
    }
}

// MARK: - Response
public struct KakaoLoginResponse: Codable, Sendable {
    public let code: String
    public let message: String
    public let data: KakaoLoginData
    public let success: Bool
}

public struct KakaoLoginData: Codable, Sendable {
    public let accessToken: String
    public let refreshToken: String
    public let existMember: Bool
}
