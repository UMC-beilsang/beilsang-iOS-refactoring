//
//  APIConstants.swift
//  beilsang
//
//  Created by Seyoung on 2/10/24.
//

import Foundation

struct APIConstants {
    //MARK: - Base URL
    static let baseURL = "https://beilsang.site"
    
    //MARK: - Feature
    // 카카오 로그인
    static let loginKakaoURL = baseURL + "/auth/kakao/login"
    
    // 애플 로그인
    static let loginAppleURL = baseURL + "/auth/apple/login"
    static let loginAppleTest = baseURL + "/auth/test/refresh"
     
    //토큰 재발급
    static let refreshTokenURL = baseURL + "/auth/token/refresh"
    
    //자체 회원가입
    static let signUpURL = baseURL + "/auth/signup"
    
    //닉네임 중복 체크
    static let duplicateCheck = baseURL + "/api/join/check/nickname"
    
    //닉네임 존재?
    static let nicknameExist = baseURL + "/api/join/check/existnickname"
    
    //MARK: - Feature: Search
    static let searchURL = baseURL + "/api/search"
    
    //회원탈퇴
    static let kakaoWithDrawURL = baseURL + "/auth/kakao/revoke"
    static let appleWithDrawURL = baseURL + "/auth/apple/revoke"
    
    //알림
    static let notificationURL = baseURL + "/api/notifications"
}
