//
//  KakaoLoginModels.swift
//  ModelsShared
//
//  Created by Seyoung Park on 8/31/25.
//

import Foundation

// MARK: - Request
public struct KakaoLoginRequest: Codable, Sendable {
    public let idToken: String
    
    public init(idToken: String) {
        self.idToken = idToken
    }
}

// MARK: - Response
public typealias KakaoLoginResponse = APIResponse<KakaoLoginData>

public struct KakaoLoginData: Codable, Sendable {
    public let accessToken: String
    public let refreshToken: String
    /// 약관 동의 완료 또는 기존 회원 여부 (서버가 `isExistMember`만 내려주는 경우 포함)
    public let isTermsAgreed: Bool

    private enum CodingKeys: String, CodingKey {
        case accessToken
        case refreshToken
        case isTermsAgreed
        case isExistMember
    }

    public init(accessToken: String, refreshToken: String, isTermsAgreed: Bool) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.isTermsAgreed = isTermsAgreed
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accessToken = try container.decode(String.self, forKey: .accessToken)
        refreshToken = try container.decode(String.self, forKey: .refreshToken)

        let termsAgreed = try container.decodeIfPresent(Bool.self, forKey: .isTermsAgreed) ?? false
        let existMember = try container.decodeIfPresent(Bool.self, forKey: .isExistMember) ?? false
        isTermsAgreed = termsAgreed || existMember
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(accessToken, forKey: .accessToken)
        try container.encode(refreshToken, forKey: .refreshToken)
        try container.encode(isTermsAgreed, forKey: .isTermsAgreed)
    }
}
