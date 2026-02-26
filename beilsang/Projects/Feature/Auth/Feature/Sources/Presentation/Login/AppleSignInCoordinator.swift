//
//  AppleSignInCoordinator.swift
//  AuthFeature
//
//  Created by Seyoung Park on 11/25/25.
//

import AuthenticationServices
import SwiftUI
import UIKit
import AuthDomain

final class AppleSignInCoordinator: NSObject {
    typealias Completion = (Result<String, Error>) -> Void
    
    private let completion: Completion
    
    init(completion: @escaping Completion) {
        self.completion = completion
    }
    
    func start() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}

extension AppleSignInCoordinator: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard
            let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let tokenData = credential.identityToken,
            let token = String(data: tokenData, encoding: .utf8)
        else {
            completion(.failure(AuthError.appleError("애플 토큰을 가져올 수 없습니다.")))
            return
        }
        
        #if DEBUG
        if let codeData = credential.authorizationCode,
           let code = String(data: codeData, encoding: .utf8) {
            print("🔐 Apple authorizationCode: \(code)")
        } else {
            print("⚠️ Apple authorizationCode is nil")
        }
        print("🪪 Apple identityToken: \(token)")
        #endif
        
        completion(.success(token))
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        #if DEBUG
        print("❌ Apple Sign In Error: \(error)")
        if let nsError = error as NSError? {
            print("   Domain: \(nsError.domain)")
            print("   Code: \(nsError.code)")
            print("   UserInfo: \(nsError.userInfo)")
        }
        #endif
        
        // 사용자가 취소한 경우는 에러로 처리하지 않음
        if let authError = error as? ASAuthorizationError {
            switch authError.code {
            case .canceled:
                // 사용자가 취소한 경우는 조용히 무시
                #if DEBUG
                print("ℹ️ 사용자가 애플 로그인을 취소했습니다.")
                #endif
                return
            case .invalidResponse:
                completion(.failure(AuthError.appleError("애플 로그인 응답이 유효하지 않습니다. 다시 시도해주세요.")))
            case .notHandled:
                completion(.failure(AuthError.appleError("애플 로그인을 처리할 수 없습니다. Xcode에서 Sign in with Apple capability를 확인해주세요.")))
            case .failed:
                completion(.failure(AuthError.appleError("애플 로그인에 실패했습니다. 다시 시도해주세요.")))
            case .unknown:
                // 오류 코드 1000은 unknown에 해당
                let message = "애플 로그인 설정에 문제가 있을 수 있습니다. 다음을 확인해주세요:\n1. Xcode에서 Sign in with Apple capability 활성화\n2. 애플 개발자 계정에서 Bundle ID 등록 확인\n3. 프로비저닝 프로파일 확인"
                completion(.failure(AuthError.appleError(message)))
            @unknown default:
                completion(.failure(AuthError.appleError("애플 로그인 중 오류가 발생했습니다. (코드: \(authError.code.rawValue))")))
            }
        } else if let nsError = error as NSError? {
            // NSError로 변환 가능한 경우
            if nsError.domain == "com.apple.AuthenticationServices.AuthorizationError" && nsError.code == 1000 {
                let message = "애플 로그인 설정 오류입니다. Xcode 프로젝트 설정에서 Sign in with Apple capability를 확인해주세요."
                completion(.failure(AuthError.appleError(message)))
            } else if nsError.domain == "AKAuthenticationError" {
                // AKAuthenticationError (오류 코드 -7026 등)
                let message = "애플 인증 오류가 발생했습니다. (코드: \(nsError.code))\n앱의 Sign in with Apple 설정을 확인해주세요."
                completion(.failure(AuthError.appleError(message)))
            } else {
                completion(.failure(AuthError.appleError(error.localizedDescription)))
            }
        } else {
            // 기타 오류
            completion(.failure(AuthError.appleError(error.localizedDescription)))
        }
    }
}

extension AppleSignInCoordinator: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // iOS 15+ 방식: windowScene 사용
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) ?? 
            UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first else {
            #if DEBUG
            print("⚠️ No window scene found, creating fallback window")
            #endif
            return UIWindow(frame: UIScreen.main.bounds)
        }
        
        // Key window 찾기
        if let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
            return keyWindow
        }
        
        // Fallback: 첫 번째 window
        if let firstWindow = windowScene.windows.first {
            return firstWindow
        }
        
        #if DEBUG
        print("⚠️ No window found in scene, creating fallback window")
        #endif
        // 최악의 경우: 새로운 window 생성
        return UIWindow(frame: UIScreen.main.bounds)
    }
}

