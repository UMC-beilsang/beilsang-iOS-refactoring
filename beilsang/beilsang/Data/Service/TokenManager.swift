//
// TokenManager.swift
// beilsang
//
// Created by Seyoung on 2/17/24.
//
import Foundation
import UIKit

class TokenManager {
    static let shared = TokenManager()
    
    func refreshToken(refreshToken: String, completion: @escaping (NetworkResult<Any>) -> Void, callback: (() -> Void)? = nil) {
        TokenService.shared.refreshToken(refreshToken: refreshToken) { result in
            switch result {
            case .success(let data):
                guard let data = data as? TokenResponse else { return }
                print("access Token refresh Success with data : \(data)")
                KeyChain.create(key: Const.KeyChainKey.serverToken, token: data.data!.accessToken)
                KeyChain.create(key: Const.KeyChainKey.refreshToken, token: data.data!.refreshToken)
                completion(.success(data))
                callback?()
            case .networkFail:
                print("네트워크 페일")
                completion(.networkFail)
                self.navigateToLoginVC()
            case .tokenExpired:
                print("토큰 재발급 오류")
                completion(.tokenExpired)
                self.navigateToLoginVC()
            case .requestErr(let error):
                print("요청 페일 \(error)")
                completion(.requestErr(error))
                self.navigateToLoginVC()
            case .pathErr:
                print("경로 오류")
                completion(.pathErr)
                self.navigateToLoginVC()
            case .serverErr:
                print("서버 오류")
                completion(.serverErr)
                self.navigateToLoginVC()
            }
        }
    }
    
    private func navigateToLoginVC() {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate, let window = sceneDelegate.window {
            let loginVC = LoginViewController()
            UIView.transition(with: window, duration: 1.0, options: .transitionCrossDissolve, animations: {
                window.rootViewController = loginVC
            }, completion: nil)
        }
    }
}

