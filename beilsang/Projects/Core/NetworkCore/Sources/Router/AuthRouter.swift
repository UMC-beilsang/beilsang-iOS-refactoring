//
//  AuthRouter.swift
//  NetworkCore
//
//  Created by Seyoung Park on 8/31/25.
//

import Alamofire
import Foundation
import ModelsShared

public enum AuthRouter {
    case kakaoLogin(KakaoLoginRequest)
    case appleLogin(AppleLoginRequest)
    case signup(SignUpRequest)
    case refresh(String)
    case revokeKakao
    case revokeApple
    
    private var method: HTTPMethod {
        switch self {
        case .kakaoLogin, .appleLogin, .signup, .refresh: return .post
        case .revokeKakao, .revokeApple: return .delete
        }
    }
    
    private var path: String {
        switch self {
        case .kakaoLogin: return "/auth/kakao/login"
        case .appleLogin: return "/auth/apple/login"
        case .signup: return "/auth/signup"
        case .refresh: return "/auth/token/refresh"
        case .revokeKakao: return "/auth/kakao/revoke"
        case .revokeApple: return "/auth/apple/revoke"
        }
    }
    
    private var parameters: Encodable? {
        switch self {
        case .kakaoLogin(let req): return req
        case .appleLogin(let req): return req
        case .signup(let req): return req
        case .refresh(let token): return RefreshTokenRequest(from: token)
        default: return nil
        }
    }

    public func asURLRequest(baseURL: String) throws -> URLRequest {
        guard let base = URL(string: baseURL) else {
            throw AFError.invalidURL(url: baseURL)
        }
        var request = URLRequest(url: base.appendingPathComponent(path))
        request.method = method
        if let params = parameters {
            request = try JSONParameterEncoder.default.encode(params, into: request)
        }
        return request
    }
}
