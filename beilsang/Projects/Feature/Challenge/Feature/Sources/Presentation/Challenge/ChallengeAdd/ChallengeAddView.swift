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

public struct ChallengeAddView: View {
    @StateObject private var viewModel: ChallengeAddViewModel
    @StateObject private var keyboard = KeyboardResponder()
    @EnvironmentObject var toastManager: ToastManager
    @Environment(\.dismiss) private var dismiss
    @State private var scrollPosition: String? = "top"
    @EnvironmentObject var coordinator: ChallengeCoordinator

    public init(viewModel: ChallengeAddViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                Header(type: .secondary(title: "챌린지 만들기", onBack: {
                    if viewModel.currentStep == .basic {
                        dismiss()
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
                
                NextStepButton(
                    title: {
                        switch viewModel.currentStep {
                        case .basic, .detail: return "다음으로"
                        case .confirm: return "챌린지 만들기"
                        }
                    }(),
                    isEnabled: viewModel.isNextEnabled,
                    onTap: {
                        if viewModel.currentStep == .confirm {
                            viewModel.createChallenge()
                            dismiss()
                        } else {
                            viewModel.nextStep()
                        }
                    },
                    onDisabledTap: {
                        showToastForCurrentStep()
                    }
                )
                .padding(.horizontal, 24)
                .padding(.bottom, UIScreen.main.bounds.height * 0.085)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private func showToastForCurrentStep() {
        withAnimation {
            switch viewModel.currentStep {
            case .basic:
                if viewModel.title.isEmpty {
                    toastManager.show(iconName: "toastCheckIcon", message: "챌린지 제목을 입력해 주세요")
                } else if viewModel.category == nil {
                    toastManager.show(iconName: "toastCheckIcon", message: "챌린지 카테고리를 선택해 주세요")
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
                } else if viewModel.samplePhotos.count < 4 {
                    toastManager.show(iconName: "toastCheckIcon", message: "모범 인증 사진을 등록해 주세요")
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

