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
    public let authorizationCode: String
    
    public init(identityToken: String, authorizationCode: String) {
        self.identityToken = identityToken
        self.authorizationCode = authorizationCode
    }
}

// MARK: - Response Envelope
/// 서버 응답 봉투. 서버가 `statusCode`(Int) 또는 `isSuccess`(Bool) 중 무엇을 내려주든 대응한다.
/// 토큰은 바디의 `data`에 담겨오거나 응답 헤더로 내려올 수 있어 모두 옵셔널로 둔다.
public struct AppleLoginEnvelope: Decodable, Sendable {
    public let statusCode: Int?
    public let isSuccess: Bool?
    public let code: String?
    public let message: String?
    public let data: AppleLoginData?

    public var success: Bool {
        if let isSuccess { return isSuccess }
        if let statusCode { return statusCode == 200 }
        return false
    }

    public var resolvedMessage: String {
        message ?? "알 수 없는 오류가 발생했습니다."
    }
}

// MARK: - Response Data (바디에 토큰이 담겨올 경우)
public struct AppleLoginData: Decodable, Sendable {
    public let accessToken: String?
    public let refreshToken: String?
    /// 약관 동의 완료 또는 기존 회원 여부
    public let isTermsAgreed: Bool

    private enum CodingKeys: String, CodingKey {
        case accessToken
        case refreshToken
        case isTermsAgreed
        case isExistMember
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accessToken = try container.decodeIfPresent(String.self, forKey: .accessToken)
        refreshToken = try container.decodeIfPresent(String.self, forKey: .refreshToken)

        let termsAgreed = try container.decodeIfPresent(Bool.self, forKey: .isTermsAgreed) ?? false
        let existMember = try container.decodeIfPresent(Bool.self, forKey: .isExistMember) ?? false
        isTermsAgreed = termsAgreed || existMember
    }
}
