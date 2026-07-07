//
//  AuthError.swift
//  ModelsShared
//
//  Created by Seyoung Park on 9/1/25.
//

import Foundation
import StorageCore

/// 인증 관련 에러 정의 (로그인, 회원가입, 토큰 관리 등)
public enum AuthError: Error, Equatable, Sendable, LocalizedError {
    // 로그인 관련
    case invalidCredentials       // 로그인 정보 불일치
    
    // 회원가입 관련
    case signUpFailed(String)     // 회원가입 실패
    
    // 토큰 관련
    case tokenExpired             // 토큰 만료
    
    // 외부 인증
    case kakaoError(String)       // 카카오 SDK 관련 에러
    case appleError(String)       // 애플 로그인 관련 에러
    
    // HTTP & 네트워크
    case httpError(statusCode: Int)  // HTTP 상태 코드 에러
    case networkError             // 네트워크 오류
    case serverError(String)      // 서버 에러 (메시지 포함)
    
    // 데이터 처리
    case decodingError(String)    // JSON 디코딩 실패
    case encodingError(String)    // JSON 인코딩 실패
    
    // 공통
    case unknownError(String)     // 알 수 없는 에러
    
    public var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "로그인 정보가 올바르지 않습니다."
        case .signUpFailed(let msg):
            return "회원가입 실패: \(msg)"
        case .tokenExpired:
            return "로그인이 만료되었습니다. 다시 로그인해주세요."
        case .kakaoError(let msg):
            return "카카오 로그인 오류: \(msg)"
        case .appleError(let msg):
            return "애플 로그인 오류: \(msg)"
        case .httpError(let statusCode):
            return "서버 오류가 발생했습니다. (HTTP \(statusCode))"
        case .networkError:
            return "네트워크 연결을 확인해주세요."
        case .serverError(let msg):
            return "서버 오류: \(msg)"
        case .decodingError(let msg):
            return "데이터 처리 오류: \(msg)"
        case .encodingError(let msg):
            return "데이터 처리 오류: \(msg)"
        case .unknownError(let msg):
            return "알 수 없는 오류: \(msg)"
        }
    }

    // Equatable 구현
    public static func == (lhs: AuthError, rhs: AuthError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidCredentials, .invalidCredentials),
             (.tokenExpired, .tokenExpired),
             (.networkError, .networkError):
            return true
        case (.signUpFailed(let a), .signUpFailed(let b)),
             (.kakaoError(let a), .kakaoError(let b)),
             (.appleError(let a), .appleError(let b)),
             (.serverError(let a), .serverError(let b)),
             (.decodingError(let a), .decodingError(let b)),
             (.encodingError(let a), .encodingError(let b)),
             (.unknownError(let a), .unknownError(let b)):
            return a == b
        case (.httpError(let a), .httpError(let b)):
            return a == b
        default:
            return false
        }
    }
}

public extension AuthError {
    static func fromKeychainError(_ error: KeychainError) -> AuthError {
        switch error {
        case .encodingFailed(let message):
            return .encodingError(message)
        case .decodingFailed(let message):
            return .decodingError(message)
        case .keychainSaveFailed(let status):
            return .serverError("토큰 저장에 실패했습니다. (status: \(status))")
        case .keychainLoadFailed(let status):
            return .serverError("토큰 조회에 실패했습니다. (status: \(status))")
        case .keychainDeleteFailed(let status):
            return .serverError("토큰 삭제에 실패했습니다. (status: \(status))")
        }
    }
}
