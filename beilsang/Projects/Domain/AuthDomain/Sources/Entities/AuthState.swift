//
//  AuthState.swift
//  ModelsShared
//
//  Created by Seyoung Park on 8/31/25.
//

import Foundation

/// 인증 상태 (로그인, 회원가입 등 인증 플로우 전반)
public enum AuthState: Equatable {
    case idle                         // 대기 중
    case loading                      // 처리 중 (로그인, 회원가입 등)
    case authenticated                // 인증 완료 (기존 회원)
    case needsSignUp                  // 인증 완료 but 회원가입 필요 (신규 회원)
    case unauthenticated              // 미인증
    case tokenExpired                 // 토큰 만료
    case error(AuthError)             // 에러
}
