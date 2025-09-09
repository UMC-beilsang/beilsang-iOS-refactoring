//
//  AuthError.swift
//  ModelsShared
//
//  Created by Seyoung Park on 9/1/25.
//

import Foundation

// 인증 관련 에러 정의
public enum AuthError: Error, Equatable, Sendable {
    case invalidCredentials       // 로그인 정보 불일치
    case tokenExpired             // 토큰 만료
    case networkError             // 네트워크 오류
    case serverError(String)      // 서버 에러 (메시지 포함)
    case kakaoError(String)       // 카카오 SDK 관련 에러
    case appleError(String)       // 애플 로그인 관련 에러
    case unknownError(String)     // 알 수 없는 에러
}
