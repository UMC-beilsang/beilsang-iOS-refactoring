//
//  RevokeToken.swift
//  beilsang
//
//  Created by Seyoung on 5/20/24.
//

import Foundation

// MARK: - 애플 엑세스 토큰 발급 응답 모델
struct AppleTokenResponse: Codable {
    let refreshToken: String?
    
    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
}
