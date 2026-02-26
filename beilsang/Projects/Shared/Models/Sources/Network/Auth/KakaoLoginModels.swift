//
//  KakaoLoginModels.swift
//  ModelsShared
//
//  Created by Seyoung Park on 8/31/25.
//

import Foundation

// MARK: - Request
/// 카카오 로그인 요청
/// 서버 스펙: idToken(카카오 ID 토큰) 전달
public struct KakaoLoginRequest: Codable, Sendable {
    public let idToken: String
    
    public init(idToken: String) {
        self.idToken = idToken
    }
}

// MARK: - Response
/// 서버 응답: APIResponse 형태로 래핑됨
public typealias KakaoLoginResponse = APIResponse<KakaoLoginData>

public struct KakaoLoginData: Codable, Sendable {
    public let accessToken: String
    public let refreshToken: String
    public let isExistMember: Bool
    
    public init(accessToken: String, refreshToken: String, isExistMember: Bool) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.isExistMember = isExistMember
    }
}
