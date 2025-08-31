//
//  AuthState.swift
//  ModelsShared
//
//  Created by Seyoung Park on 8/31/25.
//

import Foundation

// 인증 상태 (UI & 비즈니스 공통)
public enum AuthState: Equatable {
    case unauthenticated              // 로그인 안 됨
    case authenticating               // 로그인 시도 중
    case authenticated // 로그인 완료 (토큰 있음)
    case tokenExpired                 // 토큰 만료됨
    case error(AuthError)             // 에러 발생
}
