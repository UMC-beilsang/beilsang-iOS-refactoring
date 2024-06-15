//
//  AppleGetCodeManger.swift
//  beilsang
//
//  Created by Seyoung on 5/30/24.
//

import Foundation
import AuthenticationServices

class AppleLoginManager: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    static let shared = AppleLoginManager()
    
    // 애플 로그인 요청 시작
    func startLogin() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        // 인증 코드 및 사용자 정보를 요청합니다.
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    // ASAuthorizationControllerDelegate 메서드 구현
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // Convert the authorization code to a String.
            if let authorizationCodeData = appleIDCredential.authorizationCode,
               let authorizationCode = String(data: authorizationCodeData, encoding: .utf8),
               let identityTokenData = appleIDCredential.identityToken,
               let identityToken = String(data: identityTokenData, encoding: .utf8) {
                //authorizationCode 저장
                KeyChain.create(key: Const.KeyChainKey.authorizationCode, token: authorizationCode)
                
                // MyPageService를 통해 애플 탈퇴 처리
                MyPageService.shared.DeleteAppleWithDraw { response in
                    print(response.message)
                    // 애플 탈퇴 처리 후 애플 로그아웃
                    print("apple withdraw Success!")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { // 1.5초 딜레이
                        let accountInfo = AccountInfoViewController()
                        accountInfo.appleLogout()
                    }
                }
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // 에러 처리 로직을 여기에 구현합니다.
        print("Error: \(error.localizedDescription)")
    }
    
    // ASAuthorizationControllerPresentationContextProviding 메서드 구현
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // 애플 로그인 화면을 표시할 뷰 컨트롤러의 뷰를 반환합니다.
        return UIApplication.shared.windows.first(where: { $0.isKeyWindow })!
    }
}
