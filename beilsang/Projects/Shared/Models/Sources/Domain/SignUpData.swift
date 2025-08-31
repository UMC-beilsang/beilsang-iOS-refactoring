//
//  SignUpData.swift
//  ModelsShared
//
//  Created by Seyoung Park on 8/31/25.
//

import Foundation

// 회원가입 시 UI에서 입력받는 데이터 모델
public struct SignUpData: Equatable {
    public var accessToken: String = ""        // 소셜 로그인에서 받은 토큰
    public var gender: String = ""             // 성별
    public var nickName: String = ""           // 닉네임
    public var birth: String = ""              // 생년월일
    public var address: String = ""            // 주소
    public var keyword: Keyword? = nil         // 관심 키워드 (enum)
    public var discoveredPath: String = ""     // 앱을 알게 된 경로
    public var resolution: String = ""         // 가입 동기/목표
    public var recommendNickname: String = ""  // 추천인 닉네임
    
    public init() {}
    
    // 서버 전송용 Request로 변환
    public func toRequest() -> SignUpRequest {
        SignUpRequest(
            accessToken: accessToken,
            gender: gender,
            nickName: nickName,
            birth: birth,
            address: address,
            keyword: keyword?.rawValue ?? "",
            discoveredPath: discoveredPath,
            resolution: resolution,
            recommendNickname: recommendNickname
        )
    }
}
