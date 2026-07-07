//
//  ChallengeAddView.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 10/3/25.
//

import SwiftUI
import UIComponentsShared
import ModelsShared
import DesignSystemShared
import UtilityShared
import ChallengeDomain
import NavigationShared

public struct ChallengeAddView: View {
    @ObservedObject private var viewModel: ChallengeAddViewModel
    @StateObject private var keyboard = KeyboardResponder()
    @EnvironmentObject var toastManager: ToastManager
    @Environment(\.dismiss) private var dismiss
    @State private var scrollPosition: String? = "top"
    @State private var showExitPopup: Bool = false
    @EnvironmentObject var coordinator: ChallengeCoordinator
    
    public init(viewModel: ChallengeAddViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                Header(type: .secondary(title: "챌린지 만들기", onBack: {
                    if viewModel.currentStep == .basic {
                        showExitPopup = true
                    } else {
                        viewModel.previousStep()
                    }
                }))
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        StepProgressView(currentIndex: viewModel.currentStep.rawValue, totalSteps: 3)
                            .padding(.top, 20)
                            .padding(.horizontal, 24)
                            .id("top")
                        
                        ZStack {
                            switch viewModel.currentStep {
                            case .basic:
                                ChallengeAddBasicView(viewModel: viewModel)
                                    .transition(transitionForCurrentDirection)
                                    .id("basic")
                            case .detail:
                                ChallengeAddDetailView(viewModel: viewModel)
                                    .transition(transitionForCurrentDirection)
                                    .id("detail")
                            case .confirm:
                                ChallengeAddConfirmView(viewModel: viewModel)
                                    .transition(transitionForCurrentDirection)
                                    .id("confirm")
                            }
                        }
                        .animation(.easeInOut, value: viewModel.currentStep)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)
                        
                        Spacer(minLength: UIScreen.main.bounds.height * 0.2)
                    }
                }
                .scrollPosition(id: $scrollPosition, anchor: .top)
                .onChange(of: viewModel.currentStep) { _, _ in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        scrollPosition = "top"
                    }
                }
                .padding(.bottom, keyboard.currentHeight)
                .scrollBounceBehavior(.basedOnSize)
            }
            
            ZStack {
                BottomOverlayGradient()
                    .frame(height: UIScreen.main.bounds.height * 0.17)
                    .allowsHitTesting(false)
                
                HStack(spacing: 12) {
                    if viewModel.currentStep != .basic {
                        Button {
                            viewModel.previousStep()
                        } label: {
                            Text("이전")
                                .fontStyle(Fonts.heading2Bold)
                                .foregroundStyle(ColorSystem.labelNormalBasic)
                                .frame(width: 80, height: 60)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(ColorSystem.labelNormalAlternative)
                                )
                        }
                        .transition(.move(edge: .leading).combined(with: .opacity))
                    }
                    
                    NextStepButton(
                        title: {
                            switch viewModel.currentStep {
                            case .basic, .detail: return "다음으로"
                            case .confirm: return "챌린지 만들기"
                            }
                        }(),
                        isEnabled: viewModel.isNextEnabled && !viewModel.isCreating,
                        onTap: {
                            guard viewModel.isNextEnabled && !viewModel.isCreating else { return }
                            if viewModel.currentStep == .confirm {
                                Task {
                                    do {
                                        try await viewModel.createChallenge()
                                        let toast = toastManager
                                        dismissKeyboard()
                                        dismiss()
                                        try? await Task.sleep(nanoseconds: 300_000_000)
                                        toast.show(iconName: "toastCheckIcon", message: "챌린지가 생성되었습니다!")
                                    } catch {
                                        let message = (error as? LocalizedError)?.errorDescription ?? "챌린지 생성에 실패했어요"
                                        toastManager.show(iconName: "toastWarningIcon", message: message)
                                    }
                                }
                            } else {
                                viewModel.nextStep()
                            }
                        },
                        onDisabledTap: {
                            showToastForCurrentStep()
                        }
                    )
                }
                .animation(.easeInOut(duration: 0.2), value: viewModel.currentStep)
                .padding(.horizontal, 24)
                .padding(.bottom, UIScreen.main.bounds.height * 0.085)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            await viewModel.fetchUserPoints()
        }
        .overlay {
            if showExitPopup {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .overlay {
                        PopupView(
                            title: "챌린지 만들기를 그만할까요?",
                            style: .alert(
                                message: "지금 나가면 작성한 내용이 모두 사라져요.",
                                subMessage: nil
                            ),
                            primary: PopupAction(title: "나가기") {
                                showExitPopup = false
                                dismissKeyboard()
                                dismiss()
                            },
                            secondary: PopupAction(title: "계속 만들기") {
                                showExitPopup = false
                            }
                        )
                    }
            }
        }
        .overlay {
            if viewModel.showInsufficientPointsPopup {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .overlay {
                        PopupView(
                            title: "포인트가 부족해요",
                            style: .content(type: .point(
                                minRequiredPoint: 100,
                                earnedPoint: viewModel.userPoints
                            )),
                            primary: PopupAction(title: "확인") {
                                dismissKeyboard()
                                dismiss()
                            }
                        )
                    }
            }
        }
        .overlay {
            if viewModel.isCreating {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .overlay {
                        ChallengeCreatingLoadingView()
                    }
                    .transition(.opacity)
                    .zIndex(2)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.isCreating)
        .onDisappear {
            dismissKeyboard()
        }
    }
    
    private func showToastForCurrentStep() {
        withAnimation {
            switch viewModel.currentStep {
            case .basic:
                if viewModel.title.isEmpty {
                    toastManager.show(iconName: "toastCheckIcon", message: "챌린지 제목을 입력해 주세요")
                } else if viewModel.category == nil {
                    toastManager.show(iconName: "toastCheckIcon", message: "챌린지 카테고리를 선택해 주세요")
                } else if viewModel.representativePhotos.contains(where: { $0.isFailed }) {
                    toastManager.show(iconName: "toastWarningIcon", message: "오류난 대표 이미지를 삭제하고 다시 등록해 주세요")
                } else if viewModel.representativePhotos.contains(where: { $0.isLoading }) {
                    toastManager.show(iconName: "toastCheckIcon", message: "대표 이미지 업로드가 끝날 때까지 기다려 주세요")
                } else if viewModel.representativePhotos.isEmpty {
                    toastManager.show(iconName: "toastCheckIcon", message: "대표 이미지를 등록해 주세요")
                } else if viewModel.period == nil {
                    toastManager.show(iconName: "toastCheckIcon", message: "챌린지 기간을 선택해 주세요")
                } else {
                    toastManager.show(iconName: "toastCheckIcon", message: "챌린지 기본 정보를 모두 입력해 주세요")
                }
                
            case .detail:
                if !viewModel.isDescriptionValid {
                    toastManager.show(iconName: "toastCheckIcon", message: "챌린지 세부 설명을 입력해 주세요")
                } else if !viewModel.isCautionValid {
                    toastManager.show(iconName: "toastCheckIcon", message: "챌린지 인증 유의사항을 입력해 주세요")
                } else if viewModel.samplePhotos.contains(where: { $0.isFailed }) {
                    toastManager.show(iconName: "toastWarningIcon", message: "오류난 모범 인증 사진을 삭제하고 다시 등록해 주세요")
                } else if viewModel.samplePhotos.contains(where: { $0.isLoading }) {
                    toastManager.show(iconName: "toastCheckIcon", message: "모범 인증 사진 업로드가 끝날 때까지 기다려 주세요")
                } else if viewModel.samplePhotos.filter({ $0.image != nil }).count < 4 {
                    toastManager.show(iconName: "toastCheckIcon", message: "모범 인증 사진을 4장 등록해 주세요")
                } else {
                    toastManager.show(iconName: "toastCheckIcon", message: "챌린지 세부 정보를 모두 입력해 주세요")
                }
                
            case .confirm:
                toastManager.show(iconName: "toastCheckIcon", message: "모든 유의사항을 체크해 주세요")
            }
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
}

