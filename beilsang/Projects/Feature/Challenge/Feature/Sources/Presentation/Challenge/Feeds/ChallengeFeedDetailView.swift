//
//  ChallengeFeedDetailView.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/16/25.
//

import SwiftUI
import UIComponentsShared
import ModelsShared
import DesignSystemShared
import UtilityShared
import ChallengeDomain

public struct ChallengeFeedDetailView: View {
    @StateObject private var viewModel: ChallengeFeedDetailViewModel
    @State private var reportSheetDetent: PresentationDetent = .large
    @State private var localToast: (iconName: String, message: String)? = nil
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var toastManager: ToastManager
    @EnvironmentObject var coordinator: ChallengeCoordinator
    
    public init(viewModel: ChallengeFeedDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Header(type: .tertiaryReport(
                title: headerTitle,
                onBack: { dismiss() },
                onOption: {
                    // 내 피드가 아닐 때만 신고 가능
                    if let feedDetail = viewModel.feedDetail, !feedDetail.isMyFeed {
                        viewModel.showReportPopup()
                    }
                }
            ))
            
            ScrollView(.vertical, showsIndicators: false) {
                ZStack {
                    if viewModel.isLoading {
                        ChallengeFeedDetailSkeletonView()
                            .transition(.opacity)
                    } else if let feedDetail = viewModel.feedDetail {
                        VStack(alignment: .leading, spacing: 0) {
                            // 사용자 프로필 영역
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(spacing: 20) {
                                    CachedAsyncImage(url: feedDetail.memberInfo.profileImage) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Image("profilePlaceholderImage", bundle: .designSystem)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    }
                                    .frame(width: 52, height: 52)
                                    .clipShape(Circle())
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack(alignment: .center, spacing: 12) {
                                            Text(feedDetail.memberInfo.nickName ?? "")
                                                .fontStyle(.body1Bold)
                                                .foregroundStyle(ColorSystem.labelNormalStrong)
                                            
                                            Button {
                                                handleProfileTap(for: feedDetail)
                                            } label: {
                                                HStack(alignment: .center, spacing: 0){
                                                    Text("프로필 보기")
                                                        .fontStyle(.detail1Medium)
                                                        .foregroundStyle(ColorSystem.labelNormalBasic)
                                                    
                                                    Image("caretIcon", bundle: .designSystem)
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 16, height: 16)
                                                }
                                            }
                                        }
                                        
                                        Text(createdAtText)
                                            .fontStyle(.body2Medium)
                                            .foregroundColor(ColorSystem.labelNormalBasic)
                                    }
                                }
                                .padding(.top, 24)
                                
                                // 피드 이미지
                                CachedAsyncImage(url: feedDetail.feedUrl) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .aspectRatio(1.5, contentMode: .fill)
                                }
                                .frame(maxWidth: .infinity)
                                .cornerRadius(16)
                                
                                // 좋아요
                                HStack {
                                    Button {
                                        Task {
                                            await viewModel.toggleLike()
                                        }
                                    } label: {
                                        HStack(alignment: .center, spacing: 10) {
                                            Image(feedDetail.isLiked ? "feedsHeartFillIcon" : "feedsHeartIcon", bundle: .designSystem)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 28, height: 28)
                                            
                                            HStack(alignment: .center, spacing: 4) {
                                                Text("좋아요")
                                                    .fontStyle(.body1SemiBold)
                                                    .foregroundStyle(ColorSystem.labelNormalNormal)
                                                
                                                Text(" \(feedDetail.likeCount)")
                                                    .fontStyle(.body1Bold)
                                                    .foregroundColor(ColorSystem.primaryStrong)
                                            }
                                        }
                                    }
                                    Spacer()
                                }
                                
                                
                                // 피드 설명
                                if let review = feedDetail.review, !review.isEmpty {
                                    Text(review) 
                                        .fontStyle(.body2SemiBold)
                                        .foregroundStyle(ColorSystem.labelNormalNormal)
                                        .lineLimit(nil)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 20)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(ColorSystem.labelNormalDisable)
                                        )
                                }
                                
                                // 챌린지 태그들
                                HStack(alignment: .center, spacing: 6) {
                                    ForEach([feedDetail.challengeCategory], id: \.self) { tag in
                                        Text("#\(tag)")
                                            .fontStyle(.detail1Medium)
                                            .foregroundColor(ColorSystem.primaryStrong)
                                            .padding(.horizontal, 12)
                                            .frame(minHeight: 26)
                                            .background(ColorSystem.labelNormalDisable)
                                            .cornerRadius(999)
                                    }
                                    Spacer()
                                }
                                .padding(.bottom, 16)
                            }
                            .padding(.horizontal, 24)
                            
                            // Divider
                            Rectangle()
                                .fill(ColorSystem.labelNormalDisable)
                                .frame(height: 8)
                                .padding(.top, 40)
                            
                            // 추천 챌린지
                            if !viewModel.recommendedChallenges.isEmpty {
                                ChallengeRecommendView(recommendChallenges: viewModel.recommendedChallenges, showOnlyFirst: true)
                                    .padding(.horizontal, 24)
                            }
                        }
                        .transition(.opacity)
                    }
                }
                .animation(.easeOut(duration: 0.2), value: viewModel.isLoading)
            }
            .task {
                await viewModel.loadFeedDetail()
            }
        }
    .toolbar(.hidden, for: .navigationBar)
    .fullScreenCover(item: $coordinator.presentedMemberProfile) { profile in
        coordinator.makeMemberProfileView(memberInfo: profile.memberInfo)
            .toolbar(.hidden, for: .navigationBar)
    }
    .sheet(isPresented: $viewModel.showReportSheet) {
        ReportBottomSheet(
            title: "피드 신고하기",
            onCancel: { viewModel.showReportSheet = false },
            onReasonSelected: { (reason: FeedReportReason, otherText: String?) in
                viewModel.showReportSheet = false
                Task {
                    let result = await viewModel.reportFeedFromSheet(reason: reason, otherText: otherText)
                    await MainActor.run {
                        let (iconName, message): (String, String) = {
                            switch result {
                            case .success(let msg): return ("toastCheckIcon", msg)
                            case .error(let msg):   return ("toastWarningIcon", msg)
                            default:                return ("toastCheckIcon", "")
                            }
                        }()
                        guard !message.isEmpty else { return }
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            localToast = (iconName, message)
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                localToast = nil
                            }
                        }
                    }
                }
            },
            detent: $reportSheetDetent
        )
        .presentationDragIndicator(.visible)
    }
    .overlay(alignment: .bottom) {
        if let toast = localToast {
            ToastView(iconName: toast.iconName, message: toast.message)
                .padding(.bottom, UIScreen.main.bounds.height * 0.17)
                .transition(.opacity)
        }
    }
  }
    
    private var headerTitle: String {
        guard let feedDetail = viewModel.feedDetail else {
            return "참여자 인증 사진"
        }
        
        return feedDetail.isMyFeed ? "내 인증 사진" : "참여자 인증 사진"
    }
    
    private var createdAtText: String {
        guard let feedDetail = viewModel.feedDetail else { return "" }
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: feedDetail.createdAt) else { return "" }
        
        let relative = RelativeDateTimeFormatter()
        relative.locale = Locale(identifier: "ko_KR")
        return relative.localizedString(for: date, relativeTo: Date())
    }

    private func handleProfileTap(for feedDetail: FeedDetailData) {
        if feedDetail.isMyFeed {
            coordinator.navigateToMyProfile()
        } else {
            coordinator.presentMemberProfile(feedDetail.memberInfo)
        }
    }
    
}
