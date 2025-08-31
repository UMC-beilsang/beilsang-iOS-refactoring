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

public struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel
    @Environment(\.dismiss) private var dismiss
    
    public init(container: AuthContainer) {
        self._viewModel = StateObject(
            wrappedValue: LoginViewModel(container: container)
        )
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
                        // TODO: 카카오 SDK 통해 accessToken 가져오기
                        let kakaoToken = "카카오에서받은액세스토큰"
                        let deviceToken = "APNS_DEVICE_TOKEN"
                        let request = KakaoLoginRequest(accesstoken: kakaoToken,
                                                        deviceToken: deviceToken)
                        viewModel.loginWithKakao(request: request)
                    }
                )
                .disabled(viewModel.isLoading)
                
                SocialLoginButton(
                    type: .apple,
                    action: {
                        // TODO: Apple 로그인 완료 후 identityToken 가져오기
                        let idToken = "애플에서받은IDToken"
                        let deviceToken = "APNS_DEVICE_TOKEN"
                        let request = AppleLoginRequest(idToken: idToken,
                                                        deviceToken: deviceToken)
                        viewModel.loginWithApple(request: request)
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
            
            if viewModel.isLoading {
                ProgressView("로그인 중...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding(.top, 16)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }
}
