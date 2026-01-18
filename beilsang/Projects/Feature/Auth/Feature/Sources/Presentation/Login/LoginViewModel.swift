//
//  LoginViewModel.swift
//  AuthFeature
//
//  Created by Park Seyoung on 8/28/25.
//

import Foundation
import Combine
import SwiftUI
import ModelsShared
import AuthDomain
import StorageCore
import UtilityShared
import KakaoSDKAuth
import KakaoSDKUser

@MainActor
final class LoginViewModel: ObservableObject {
    // MARK: - Published
    @Published var authState: AuthState = .unauthenticated
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Dependencies
    private let container: AuthContainer
    private var cancellables = Set<AnyCancellable>()
    private var appleCoordinator: AppleSignInCoordinator?

    // MARK: - Init
    init(container: AuthContainer) {
        self.container = container
    }

    // MARK: - Kakao Login
    func startKakaoLogin(showWebLogin: @escaping () -> Void) {
        isLoading = true
        
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { [weak self] oauthToken, error in
                guard let self = self else { return }
                
                if let error = error {
                    #if DEBUG
                    print("⚠️ 카카오톡 앱 로그인 실패: \(error)")
                    #endif
                    self.loginWithKakaoAccount()
                    return
                }
                
                guard let oauthToken = oauthToken else {
                    #if DEBUG
                    print("⚠️ 카카오톡 앱 로그인: 토큰 없음")
                    #endif
                    self.loginWithKakaoAccount()
                    return
                }
                
                #if DEBUG
                print("✅ KakaoTalk login success")
                print("   accessToken: \(oauthToken.accessToken)")
                print("   idToken: \(oauthToken.idToken ?? "nil")")
                #endif
                
                self.sendKakaoIdTokenToServer(idToken: oauthToken.idToken)
            }
        } else {
            #if DEBUG
            print("📱 카카오톡 앱 미설치 → 카카오계정으로 로그인")
            #endif
            loginWithKakaoAccount()
        }
    }
    
    // MARK: - Kakao Account Login (카카오톡 앱 없을 때)
    private func loginWithKakaoAccount() {
        UserApi.shared.loginWithKakaoAccount { [weak self] oauthToken, error in
            guard let self = self else { return }
            
            if let error = error {
                #if DEBUG
                print("❌ 카카오계정 로그인 실패: \(error)")
                #endif
                self.isLoading = false
                self.handleAuthState(.error(.kakaoError(error.localizedDescription)))
                return
            }
            
            guard let oauthToken = oauthToken else {
                #if DEBUG
                print("❌ 카카오계정 로그인: 토큰 없음")
                #endif
                self.isLoading = false
                self.handleAuthState(.error(.kakaoError("카카오 로그인에 실패했습니다.")))
                return
            }
            
            #if DEBUG
            print("✅ KakaoAccount login success")
            print("   accessToken: \(oauthToken.accessToken)")
            print("   idToken: \(oauthToken.idToken ?? "nil")")
            #endif
            
            self.sendKakaoIdTokenToServer(idToken: oauthToken.idToken)
        }
    }
    
    // MARK: - Send Kakao ID Token to Server
    private func sendKakaoIdTokenToServer(idToken: String?) {
        guard let idToken = idToken, !idToken.isEmpty else {
            #if DEBUG
            print("❌ 카카오 ID 토큰이 없습니다.")
            #endif
            self.isLoading = false
            self.handleAuthState(.error(.kakaoError("카카오 ID 토큰을 가져올 수 없습니다.")))
            return
        }
        
        let request = KakaoLoginRequest(idToken: idToken)
        self.loginWithKakao(request: request)
    }
    
    // MARK: - Kakao Login
    func loginWithKakao(request: KakaoLoginRequest) {
        container.kakaoLoginUseCase.login(request: request)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleAuthState(state)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Kakao Web Login
    func handleKakaoWebLoginSuccess(accessToken: String, refreshToken: String, isExistMember: Bool) {
        isLoading = true
        
        // 카카오 로그인 provider 정보 추가
        let token = KeychainToken(
            accessToken: accessToken,
            refreshToken: refreshToken,
            provider: .kakao
        )
        container.tokenStorage.saveToken(token)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.handleAuthState(.error(.kakaoError(error.localizedDescription)))
                    }
                },
                receiveValue: { [weak self] in
                    #if DEBUG
                    print("✅ 카카오 로그인 성공 - 토큰 저장 완료")
                    print("   isExistMember: \(isExistMember)")
                    #endif
                    
                    if isExistMember {
                        self?.handleAuthState(.authenticated)
                    } else {
                        self?.handleAuthState(.needsSignUp)
                    }
                }
            )
            .store(in: &cancellables)
    }

    // MARK: - Apple Login
    func startAppleLogin() {
        isLoading = true
        let coordinator = AppleSignInCoordinator { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let token):
                let request = AppleLoginRequest(idToken: token)
                self.loginWithApple(request: request)
            case .failure(let error):
                self.handleAuthState(.error(.appleError(error.localizedDescription)))
            }
            self.appleCoordinator = nil
        }
        appleCoordinator = coordinator
        coordinator.start()
    }
    
    func loginWithApple(request: AppleLoginRequest) {
        container.appleLoginUseCase.login(request: request)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleAuthState(state)
            }
            .store(in: &cancellables)
    }

    // MARK: - Helpers
    func clearError() {
        errorMessage = nil
    }
    
    func handleKakaoError(_ message: String) {
        handleAuthState(.error(.kakaoError(message)))
    }

    private func handleAuthState(_ state: AuthState) {
        authState = state
        switch state {
        case .loading:
            isLoading = true
            errorMessage = nil
        case .authenticated:
            isLoading = false
        case .error(let error):
            isLoading = false
            errorMessage = error.localizedDescription
        default:
            isLoading = false
        }
    }
}
