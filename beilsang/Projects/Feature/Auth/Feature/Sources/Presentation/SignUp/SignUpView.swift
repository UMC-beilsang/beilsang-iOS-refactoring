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
    @StateObject private var keyboard = KeyboardResponder()
    @EnvironmentObject var toastManager: ToastManager
    @Environment(\.dismiss) private var dismiss
    
    private let onSignUpComplete: () -> Void
    
    public init(
        signUpData: SignUpData = .init(),
        container: AuthContainer,
        onSignUpComplete: @escaping () -> Void = {}
    ) {
        self._viewModel = StateObject(
            wrappedValue: SignUpViewModel(
                signUpData: signUpData,
                container: container
            )
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
                // 나머지 단계
                VStack(alignment: .leading, spacing: 0) {
                    Header(type: .secondary(title: "회원가입", onBack: {
                        if viewModel.currentStep == .terms {
                            dismiss()
                        } else {
                            viewModel.previousStep()
                        }
                    }))
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            StepProgressView(
                                currentIndex: viewModel.currentStep.rawValue,
                                totalSteps: 5
                            )
                            .padding(.top, 20)
                            .padding(.horizontal, 24)
                            
                            // Step별 뷰
                            ZStack {
                                switch viewModel.currentStep {
                                case .terms:
                                    AgreeTermsStepView(viewModel: viewModel)
                                        .transition(transitionForCurrentDirection)
                                case .keywords:
                                    KeywordSelectionStepView(viewModel: viewModel)
                                        .id("keywords")
                                        .transition(transitionForCurrentDirection)
                                case .motto:
                                    MottoSelectionStepView(viewModel: viewModel)
                                        .transition(transitionForCurrentDirection)
                                case .info:
                                    UserInfoStepView(viewModel: viewModel)
                                        .transition(transitionForCurrentDirection)
                                case .referral:
                                    ReferralStepView(viewModel: viewModel)
                                        .transition(transitionForCurrentDirection)
                                case .complete:
                                    EmptyView()
                                }
                            }
                            .animation(.easeInOut, value: viewModel.currentStep)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 20)
                            
                            Spacer(minLength: UIScreen.main.bounds.height * 0.2)
                        }
                    }
                    .padding(.bottom, keyboard.currentHeight)
                    .scrollBounceBehavior(.basedOnSize)
                }
                
                // 하단 버튼
                ZStack {
                    BottomOverlayGradient()
                        .frame(height: UIScreen.main.bounds.height * 0.17)
                        .allowsHitTesting(false)
                    
                    NextStepButton(
                        title: viewModel.currentStep == .referral ? "회원가입 완료" : "다음으로",
                        isEnabled: viewModel.isNextEnabled,
                        onTap: { viewModel.nextOrComplete() },
                        onDisabledTap: { showToastForCurrentStep() }
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
    
    private var transitionForCurrentDirection: AnyTransition {
        switch viewModel.navigationDirection {
        case .forward:
            return .asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            )
        case .backward:
            return .asymmetric(
                insertion: .move(edge: .leading).combined(with: .opacity),
                removal: .move(edge: .trailing).combined(with: .opacity)
            )
        }
    }
    
    private func showToastForCurrentStep() {
        switch viewModel.currentStep {
        case .terms:
            toastManager.show(iconName: "toastCheckIcon", message: "필수 약관에 모두 동의해 주세요")
        case .keywords:
            toastManager.show(iconName: "toastCheckIcon", message: "키워드를 선택해 주세요")
        case .motto:
            toastManager.show(iconName: "toastCheckIcon", message: "다짐을 한 가지 선택해 주세요")
        case .info:
            if viewModel.nicknameState != .valid {
                toastManager.show(iconName: "toastWarningIcon", message: "닉네임 중복 확인이 필요합니다")
            } else {
                toastManager.show(iconName: "toastCheckIcon", message: "정보를 모두 입력해 주세요")
            }
        case .referral:
            toastManager.show(iconName: "toastCheckIcon", message: "알게된 경로를 선택해 주세요")
        case .complete:
            break
        }
    }
}
