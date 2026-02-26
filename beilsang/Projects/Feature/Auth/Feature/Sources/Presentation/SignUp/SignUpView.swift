//
//  SignUpView.swift
//  AuthFeature
//
//  Created by Park Seyoung on 8/28/25.
//

import SwiftUI
import UIComponentsShared
import ModelsShared
import DesignSystemShared
import UtilityShared
import AuthDomain

public struct SignUpView: View {
    @StateObject private var viewModel: SignUpViewModel
    @EnvironmentObject var toastManager: ToastManager
    @Environment(\.dismiss) private var dismiss
    
    private let onSignUpComplete: () -> Void
    
    public init(
        container: AuthContainer,
        onSignUpComplete: @escaping () -> Void = {}
    ) {
        self._viewModel = StateObject(
            wrappedValue: SignUpViewModel(container: container)
        )
        self.onSignUpComplete = onSignUpComplete
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            if viewModel.currentStep == .complete {
                // 회원가입 완료 뷰
                SignupCompleteView(
                    viewModel: viewModel,
                    onStart: onSignUpComplete
                )
                .ignoresSafeArea(edges:.all)
            } else {
                // 약관 동의 단계
                VStack(alignment: .leading, spacing: 0) {
                    Header(type: .secondary(title: "회원가입", onBack: {
                        dismiss()
                    }))
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            AgreeTermsStepView(viewModel: viewModel)
                                .padding(.top, 20)
                            
                            Spacer(minLength: UIScreen.main.bounds.height * 0.2)
                        }
                    }
                    .scrollBounceBehavior(.basedOnSize)
                }
                
                // 하단 버튼
                ZStack {
                    BottomOverlayGradient()
                        .frame(height: UIScreen.main.bounds.height * 0.17)
                        .allowsHitTesting(false)
                    
                    NextStepButton(
                        title: "회원가입 완료",
                        isEnabled: viewModel.isNextEnabled,
                        onTap: { viewModel.nextOrComplete() },
                        onDisabledTap: {
                            toastManager.show(iconName: "toastCheckIcon", message: "필수 약관에 모두 동의해 주세요")
                        }
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, UIScreen.main.bounds.height * 0.085)
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .toolbar(.hidden, for: .navigationBar)
        .alert(item: $viewModel.alert) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text("확인")) {
                    viewModel.clearError()
                }
            )
        }
    }
}
