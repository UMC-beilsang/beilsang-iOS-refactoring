//
//  LoginView.swift
//  AuthFeature
//
//  Created by Park Seyoung on 8/28/25.
//

import SwiftUI
import Combine
import DesignSystemShared
import ModelsShared
import AuthDomain

public struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showKakaoWebLogin = false
    
    private let baseURL: String
    private let onLoginSuccess: (Bool) -> Void  // isNewMember
    
    public init(
        container: AuthContainer,
        baseURL: String,
        onLoginSuccess: @escaping (Bool) -> Void = { _ in }
    ) {
        self._viewModel = StateObject(
            wrappedValue: LoginViewModel(container: container)
        )
        self.baseURL = baseURL
        self.onLoginSuccess = onLoginSuccess
    }
    
    public var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                swipeableImageView
                Spacer()
                bottomButtonSection
            }
        }
        .alert("로그인 오류", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("확인") {
                viewModel.clearError()
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
        .fullScreenCover(isPresented: $showKakaoWebLogin) {
            KakaoWebLoginView(
                baseURL: baseURL,
                onSuccess: { accessToken, refreshToken, isExistMember in
                    viewModel.handleKakaoWebLoginSuccess(
                        accessToken: accessToken,
                        refreshToken: refreshToken,
                        isExistMember: isExistMember
                    )
                },
                onFailure: { error in
                    viewModel.handleKakaoError(error)
                }
            )
        }
        .onChange(of: viewModel.authState) { _, newState in
            handleAuthStateChange(newState)
        }
    }
    
    private func handleAuthStateChange(_ state: AuthState) {
        switch state {
        case .authenticated:
            // 기존 회원 로그인 성공
            onLoginSuccess(false)
        case .needsSignUp:
            // 신규 회원 - 회원가입 필요
            onLoginSuccess(true)
        default:
            break
        }
    }
    
    private var swipeableImageView: some View {
        SwipeableImageCarousel()
            .frame(height: UIScreen.main.bounds.height * 0.6)
    }
    
    private var bottomButtonSection: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                SocialLoginButton(
                    type: .kakao,
                    action: {
                        viewModel.startKakaoLogin {
                            showKakaoWebLogin = true
                        }
                    }
                )
                .disabled(viewModel.isLoading)
                
                SocialLoginButton(
                    type: .apple,
                    action: {
                        viewModel.startAppleLogin()
                    }
                )
                .disabled(viewModel.isLoading)
            }
            
            Button("비회원으로 시작하기") {
                // TODO: 비회원 로직
            }
            .fontStyle(Fonts.detail1Medium)
            .foregroundColor(ColorSystem.labelNormalBasic)
            .padding(.top, 8)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }
}
