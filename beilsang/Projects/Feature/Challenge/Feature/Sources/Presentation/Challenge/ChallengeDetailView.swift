//
//  ChallengeDetailView.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/2/25.
//

import SwiftUI
import UIComponentsShared
import ModelsShared
import DesignSystemShared
import UtilityShared
import ChallengeDomain

struct ChallengeDetailView: View {
    @StateObject private var viewModel: ChallengeDetailViewModel
    @StateObject private var keyboard = KeyboardResponder()
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var toastManager: ToastManager
    
    init(viewModel: ChallengeDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                
                Header(type: .tertiary(
                    title: "챌린지",
                    onBack: { dismiss() },
                    onOption: { viewModel.showReportPopup() }
                ))
                ScrollView(.vertical, showsIndicators: false) {
                    
                    ChallengeImageView(
                        imageURL: viewModel.imageURL,
                        participantText: viewModel.participantText
                    )
                    
                    // Section 1
                    challengeDetailSection1
                    
                    sectionDivider
                    
                    // Section 2
                    challengeDetailSection2
                    
                    if shouldShowSection3Divider {
                        sectionDivider
                    }
                    
                    // Section 3
                    challengeDetailSection3
                    
                    Spacer()
                        .frame(minHeight: UIScreen.main.bounds.height * 0.21)
                }
            }
            
            ChallengeBottomButton(
                state: viewModel.state,
                isLiked: viewModel.isLiked,
                likeCount: viewModel.likeCount,
                onLikeTap: {},
                onMainAction: { handleMainActionSelection() }
            )
        }
        .task {
            await viewModel.loadRecommendedChallenges()
        }
        .onAppear {
            showInitialToast()
        }
        .ignoresSafeArea(edges: .bottom)
        .overlay(popupOverlay)
    }
    
    // MARK: - UI Components
    
    @ViewBuilder
    private var popupOverlay: some View {
        if viewModel.showingPopup, let popupType = viewModel.currentPopupType {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { viewModel.dismissPopup() }
                
                PopupView(
                    title: popupType.title,
                    style: popupType.style,
                    primary: createPrimaryAction(for: popupType),
                    secondary: createSecondaryAction(for: popupType)
                )
            }
        }
    }
    
    private var challengeDetailSection1: some View {
        VStack(alignment: .leading, spacing: 0) {
            ChallengeTitleView(
                title: viewModel.title,
                createdAtText: viewModel.createdAtText
            )
            
            CategorySmallButton(keyword: Keyword(rawValue: viewModel.category) ?? .bicycle, action: {})
            
            ChallengeInfoView(
                state: viewModel.state,
                dDayText: viewModel.dDayText,
                startDateText: viewModel.startDateText,
                depositText: viewModel.depositText,
                onProgressTap: { handleProgressTap() }
            )
        }
        .padding(.horizontal, 24)
    }
    
    private var challengeDetailSection2: some View {
        Group {
            switch viewModel.state {
            case .enrolled(let enrolledState):
                switch enrolledState {
                case .beforeStart, .inProgress, .calculating:
                    ChallengeFeedView(onSeeAllTap: {
                        // TODO: - 전체보기 액션
                    })
                    
                case .finished(let success):
                    ChallengeResultView(success: success, usePoint: 500, earnPoint: 100)
                    ChallengeFeedView(onSeeAllTap: {
                        // TODO: - 전체보기 액션
                    })
                }
                
            case .notEnrolled:
                VStack(spacing: 0) {
                    ChallengeDescriptionView(description: viewModel.description)
                    ChallengeCertView(certImages: viewModel.certImages)
                    ChallengeDepositInfoView()
                }
            }
        }
        .padding(.horizontal, 24)
    }
    
    private var challengeDetailSection3: some View {
        Group {
            switch viewModel.state {
            case .enrolled(let enrolledState):
                switch enrolledState {
                case .beforeStart, .inProgress, .calculating:
                    VStack(spacing: 0) {
                        ChallengeDescriptionView(description: viewModel.description)
                        ChallengeDepositInfoView()
                    }
                case .finished:
                    EmptyView()
                }
                
            case .notEnrolled:
                ChallengeRecommendView(recommendChallenges: viewModel.recommendChallenges)
            }
        }
        .padding(.horizontal, 24)
    }
    
    private var sectionDivider: some View {
        Rectangle()
            .fill(ColorSystem.labelNormalDisable)
            .frame(height: 8)
            .padding(.top, 24)
    }
    
    private var shouldShowSection3Divider: Bool {
        switch viewModel.state {
        case .enrolled(.finished):
            return false
        default:
            return true
        }
    }
    
    // MARK: - UI Event Handlers (View 책임)
    
    private func showInitialToast() {
        let message: String? = {
            switch viewModel.state {
            case .notEnrolled(.canApply):
                return "함께 참여하고 친환경 일상을 만들어요!"
            default:
                return nil
            }
        }()
        
        if let message = message {
            toastManager.show(iconName: "toastEcoIcon", message: message)
        }
    }
    
    private func handleProgressTap() {
        switch viewModel.state {
        case .enrolled(.inProgress(_)):
            let progressPercent = Int(viewModel.progress)
            toastManager.show(
                iconName: "toastBuldIcon",
                message: "현재 진행도는 \(progressPercent)%입니다"
            )
        default:
            break
        }
    }
    
    // MARK: - Popup Action Creators
    
    private func createPrimaryAction(for popupType: ChallengePopupType) -> PopupAction? {
        let action = popupType.actions.primary
        
        return PopupAction(title: action?.title ?? "") {
            Task {
                await handlePrimaryAction(for: popupType)
            }
        }
    }
    
    private func createSecondaryAction(for popupType: ChallengePopupType) -> PopupAction? {
        guard let action = popupType.actions.secondary else { return nil }
        
        return PopupAction(title: action.title) {
            viewModel.dismissPopup()
        }
    }
    
    private func handlePrimaryAction(for popupType: ChallengePopupType) async {
        let result = await viewModel.handlePrimaryAction(for: popupType)
        
        // View 책임: UI 피드백 처리
        await MainActor.run {
            handleActionResult(result, for: popupType)
        }
    }
    
    // MARK: - Action Result Handling (View 책임)
    
    private func handleActionResult(_ result: ChallengeActionResult, for popupType: ChallengePopupType) {
        switch result {
        case .success(let message):
            showSuccessToast(message: message, for: popupType)
            
        case .error(let message):
            toastManager.show(iconName: "toastWarningIcon", message: message)
            
        case .navigateToPointCharge:
            // TODO: 포인트 충전 화면으로 네비게이션
            toastManager.show(iconName: "toastCheckIcon", message: "포인트 충전 화면으로 이동합니다")
            
        case .none:
            break
        }
    }
    
    private func showSuccessToast(message: String, for popupType: ChallengePopupType) {
        let iconName: String = {
            switch popupType {
            case .participate:
                return "toastCheckIcon"
            case .report:
                return "toastWarningIcon"
            default:
                return "toastCheckIcon"
            }
        }()
        
        toastManager.show(iconName: iconName, message: message)
    }
    
    // MARK: - Main Action Handler
    
    private func handleMainActionSelection() {
        switch viewModel.state {
        case .notEnrolled(.canApply), .enrolled(.calculating):
            // 팝업이 필요한 액션들은 ViewModel에서 처리
            viewModel.handleMainAction()
            
        case .enrolled(.beforeStart):
            handleBeforeStartAction()
            
        case .enrolled(.inProgress(let canCertify)):
            handleInProgressAction(canCertify: canCertify)
            
        default:
            break
        }
    }
    
    private func handleBeforeStartAction() {
        let calendar = Calendar.current
        let daysUntilStart = calendar.dateComponents([.day], from: Date(), to: viewModel.startDate).day ?? 0
        toastManager.show(
            iconName: "toastCalenderIcon",
            message: "챌린지가 \(daysUntilStart)일 뒤에 시작합니다!"
        )
    }
    
    private func handleInProgressAction(canCertify: Bool) {
        if canCertify {
            Task {
                // TODO: 실제 인증 API 호출
                toastManager.show(
                    iconName: "toastCheckIcon",
                    message: "오늘의 챌린지 인증을 완료했어요"
                )
                
                await viewModel.handleCertificationCompleted()
            }
        } else {
            toastManager.show(
                iconName: "toastCheckIcon",
                message: "오늘의 챌린지 인증을 완료했어요"
            )
        }
    }
}

// MARK: - Preview
struct ChallengeDetailView_Preview: PreviewProvider {
    static var previews: some View {
        FontRegister.registerFonts()
        
        let mockChallenge = Challenge(
            id: "1",
            title: "플로깅",
            description: """
            일주일에 한 번씩 길을 걸으며 플로깅을 해보는 건 어떨까요?
            '우리 가치 플로깅하자'는 챌린저 분들이 함께 활동을 인증하며 플로깅 문화를 확장시키는 챌린지입니다! 여러분의 많은 참여 기대하겠습니다!
            """,
            category: "plogging",
            status: "CALCULATING",
            progress: 30.0,
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 30),
            currentParticipants: 30,
            maxParticipants: 100,
            depositAmount: 1000,
            certificationMethod: "사진 인증",
            infoImageUrls: ["challengeThumbnail1"],
            certImageUrls: ["challengeThumbnail1", "challengeThumbnail2", "challengeThumbnail1"],
            thumbnailImageUrl: "challengeThumbnail1",
            isLiked: false,
            likeCount: 5,
            isParticipating: true,
            createdAt: Date()
        )
        
        let mockRepository = MockChallengeRepository()
        
        return Group {
            // 미참여 상태
            ChallengeDetailView(
                viewModel: ChallengeDetailViewModel(
                    challenge: Challenge(
                        id: "1",
                        title: "플로깅 챌린지",
                        description: mockChallenge.description,
                        category: "plogging",
                        status: "RECRUITING",
                        progress: 0.0,
                        startDate: Date().addingTimeInterval(86400 * 7),
                        endDate: Date().addingTimeInterval(86400 * 37),
                        currentParticipants: 30,
                        maxParticipants: 100,
                        depositAmount: 2000,
                        certificationMethod: "사진 인증",
                        infoImageUrls: mockChallenge.infoImageUrls,
                        certImageUrls: mockChallenge.certImageUrls,
                        thumbnailImageUrl: mockChallenge.thumbnailImageUrl,
                        isLiked: false,
                        likeCount: 15,
                        isParticipating: false,
                        createdAt: Date()
                    ),
                    repository: mockRepository
                )
            )
            .previewDisplayName("미참여 - 참여가능")
            .environmentObject(ToastManager())
            
            // 참여중 - 진행중
            ChallengeDetailView(
                viewModel: ChallengeDetailViewModel(
                    challenge: Challenge(
                        id: "2",
                        title: "제로웨이스트 챌린지",
                        description: mockChallenge.description,
                        category: "zerowaste",
                        status: "IN_PROGRESS",
                        progress: 65.0,
                        startDate: Date().addingTimeInterval(-86400 * 5),
                        endDate: Date().addingTimeInterval(86400 * 25),
                        currentParticipants: 85,
                        maxParticipants: 100,
                        depositAmount: 1500,
                        certificationMethod: "사진 인증",
                        infoImageUrls: mockChallenge.infoImageUrls,
                        certImageUrls: mockChallenge.certImageUrls,
                        thumbnailImageUrl: mockChallenge.thumbnailImageUrl,
                        isLiked: true,
                        likeCount: 23,
                        isParticipating: true,
                        createdAt: Date()
                    ),
                    repository: mockRepository
                )
            )
            .previewDisplayName("참여중 - 진행중")
            .environmentObject(ToastManager())
            
            // 참여중 - 정산중
            ChallengeDetailView(
                viewModel: ChallengeDetailViewModel(
                    challenge: mockChallenge,
                    repository: mockRepository
                )
            )
            .previewDisplayName("참여중 - 정산중")
            .environmentObject(ToastManager())
            
            // 참여중 - 완료
            ChallengeDetailView(
                viewModel: ChallengeDetailViewModel(
                    challenge: Challenge(
                        id: "3",
                        title: "친환경 교통 챌린지",
                        description: mockChallenge.description,
                        category: "transport",
                        status: "ENDED_SUCCESS",
                        progress: 95.0,
                        startDate: Date().addingTimeInterval(-86400 * 35),
                        endDate: Date().addingTimeInterval(-86400 * 5),
                        currentParticipants: 78,
                        maxParticipants: 100,
                        depositAmount: 3000,
                        certificationMethod: "사진 인증",
                        infoImageUrls: mockChallenge.infoImageUrls,
                        certImageUrls: mockChallenge.certImageUrls,
                        thumbnailImageUrl: mockChallenge.thumbnailImageUrl,
                        isLiked: true,
                        likeCount: 42,
                        isParticipating: true,
                        createdAt: Date()
                    ),
                    repository: mockRepository
                )
            )
            .previewDisplayName("참여중 - 성공완료")
            .environmentObject(ToastManager())
        }
        .previewLayout(.device)
    }
}
