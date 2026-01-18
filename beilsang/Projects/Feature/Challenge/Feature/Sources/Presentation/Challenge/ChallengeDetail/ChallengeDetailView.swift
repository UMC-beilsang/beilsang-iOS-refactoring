//
//  ChallengeDetailView.swift
//  ChallengeFeature
//

import SwiftUI
import UIComponentsShared
import ModelsShared
import DesignSystemShared
import UtilityShared
import ChallengeDomain

public struct ChallengeDetailView: View {
    @StateObject private var viewModel: ChallengeDetailViewModel
    @StateObject private var keyboard = KeyboardResponder()
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var toastManager: ToastManager
    @EnvironmentObject var coordinator: ChallengeCoordinator

    public init(viewModel: ChallengeDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ZStack {
            if viewModel.isLoading {
                ChallengeDetailSkeletonView()
                    .transition(.opacity)
            }
            
            if !viewModel.isLoading, let _ = viewModel.challenge {
                contentView
                    .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.4), value: viewModel.isLoading)
        .task {
            await viewModel.loadChallengeDetail()
            await viewModel.loadFeedThumbnails()
            await viewModel.loadRecommendedChallenges()
        }
        .onAppear {
            if !viewModel.isLoading {
                showInitialToast()
            }
        }
        .onChange(of: viewModel.isLoading) { _, newValue in
            if !newValue {
                showInitialToast()
            }
        }
    }
    
    // MARK: - Content
    private var contentView: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                Header(type: .tertiaryReport(
                    title: "챌린지",
                    onBack: { dismiss() },
                    onOption: { viewModel.showReportPopup() }
                ))
                
                ScrollView(.vertical, showsIndicators: false) {
                    ChallengeImageView(
                        imageURL: viewModel.imageURL,
                        participantText: viewModel.participantText
                    )
                    
                    challengeDetailSection1
                    sectionDivider
                    challengeDetailSection2
                    
                    if shouldShowSection3Divider {
                        sectionDivider
                    }
                    
                    challengeDetailSection3
                    
                    Spacer()
                        .frame(minHeight: UIScreen.main.bounds.height * 0.21)
                }
            }
            
            ChallengeBottomButton(
                state: viewModel.state,
                isLiked: viewModel.challenge?.isLiked ?? false,
                likeCount: viewModel.challenge?.likeCount ?? 0,
                onLikeTap: {},
                onMainAction: { handleMainActionSelection() }
            )
        }
        .ignoresSafeArea(edges: .bottom)
        .toolbar(.hidden, for: .navigationBar)
        .overlay(popupOverlay)
        .fullScreenCover(isPresented: $viewModel.showFeeds) {
            if let challenge = viewModel.challenge {
                ChallengeFeedsView(
                    viewModel: ChallengeFeedsViewModel(
                        challengeId: challenge.id,
                        repository: viewModel.repository
                    )
                )
            }
        }
        .fullScreenCover(isPresented: $viewModel.showCertification) {
            if let challenge = viewModel.challenge {
                ChallengeCertView(
                    viewModel: ChallengeCertViewModel(
                        challengeId: challenge.id,
                        repository: viewModel.repository
                    )
                )
                .environmentObject(toastManager)
            }
        }
        .fullScreenCover(isPresented: $viewModel.showFeedDetail) {
            if let feedId = viewModel.selectedFeedId {
                ChallengeFeedDetailView(
                    viewModel: ChallengeFeedDetailViewModel(
                        feedId: feedId,
                        repository: viewModel.repository
                    )
                )
                .environmentObject(toastManager)
                .environmentObject(coordinator)
            }
        }
    }
    
    // MARK: - UI Sections
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
                startDateText: DateFormatter.frontFormatter.string(from: viewModel.startDate),
                depositText: viewModel.depositText,
                onProgressTap: { handleProgressTap() }
            )
        }
        .padding(.horizontal, 24)
    }
    
    @ViewBuilder
    private func challengeFeedSection(for state: ChallengeDetailState.EnrolledState) -> some View {
        switch state {
        case .beforeStart, .inProgress, .calculating:
            ChallengeFeedView(
                thumbnails: viewModel.feedThumbnails,
                onThumbnailTap: { thumbnail in
                    viewModel.showFeedDetail(feedId: thumbnail.id)
                },
                onSeeAllTap: { viewModel.showFeedGallery() }
            )
        case .finished(let success):
            VStack {
                ChallengeResultView(success: success, usePoint: 500, earnPoint: 100)
                ChallengeFeedView(
                    thumbnails: viewModel.feedThumbnails,
                    onThumbnailTap: { thumbnail in
                        viewModel.showFeedDetail(feedId: thumbnail.id)
                    },
                    onSeeAllTap: {
                        viewModel.showFeedGallery()
                    }
                )
            }
        }
    }

    private var challengeDetailSection2: some View {
        Group {
            switch viewModel.state {
            case .enrolled(let enrolledState):
                challengeFeedSection(for: enrolledState)
            case .notEnrolled:
                VStack(spacing: 0) {
                    ChallengeDescriptionView(description: viewModel.description)
                    ChallengeCertInfoView(certImages: viewModel.certImages)
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
    
    // MARK: - Popup Overlay
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
    
    // MARK: - Actions
    private func showInitialToast() {
        if case .notEnrolled(.canApply) = viewModel.state {
            toastManager.show(iconName: "toastEcoIcon", message: "함께 참여하고 친환경 일상을 만들어요!")
        }
    }
    
    private func handleProgressTap() {
        if case .enrolled(.inProgress(_)) = viewModel.state {
            let progressPercent = Int(viewModel.progress)
            toastManager.show(
                iconName: "toastBuldIcon",
                message: "현재 진행도는 \(progressPercent)%입니다"
            )
        }
    }
    
    private func createPrimaryAction(for popupType: ChallengePopupType) -> PopupAction? {
        let action = popupType.actions.primary
        return PopupAction(title: action?.title ?? "") {
            Task { await handlePrimaryAction(for: popupType) }
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
        await MainActor.run {
            handleActionResult(result, for: popupType)
        }
    }
    
    private func handleActionResult(_ result: ChallengeActionResult, for popupType: ChallengePopupType) {
        switch result {
        case .success(let message):
            showSuccessToast(message: message, for: popupType)
        case .error(let message):
            toastManager.show(iconName: "toastWarningIcon", message: message)
        case .navigateToPointCharge:
            toastManager.show(iconName: "toastCheckIcon", message: "포인트 충전 화면으로 이동합니다")
        case .none:
            break
        }
    }
    
    private func showSuccessToast(message: String, for popupType: ChallengePopupType) {
        let iconName: String = {
            switch popupType {
            case .participate: return "toastCheckIcon"
            case .report: return "toastWarningIcon"
            default: return "toastCheckIcon"
            }
        }()
        toastManager.show(iconName: iconName, message: message)
    }
    
    private func handleMainActionSelection() {
        switch viewModel.state {
        case .notEnrolled(.canApply), .enrolled(.calculating):
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
        let daysUntilStart = Calendar.current.dateComponents([.day], from: Date(), to: viewModel.startDate).day ?? 0
        toastManager.show(
            iconName: "toastCalenderIcon",
            message: "챌린지가 \(daysUntilStart)일 뒤에 시작합니다!"
        )
    }
    
    private func handleInProgressAction(canCertify: Bool) {
        if canCertify {
            viewModel.showCert()
        } else {
            toastManager.show(
                iconName: "toastCheckIcon",
                message: "오늘의 챌린지 인증을 완료했어요"
            )
        }
    }
}
