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
                                    AsyncImage(url: URL(string: feedDetail.userProfileImageUrl ?? "")) { image in
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
                                            Text(feedDetail.userName)
                                                .fontStyle(.body1Bold)
                                                .foregroundStyle(ColorSystem.labelNormalStrong)
                                            
                                            //TODO: Action 연결
                                            Button(action : {
                                                print("프로필 보기")
                                            }) {
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
                                AsyncImage(url: URL(string: feedDetail.feedUrl)) { image in
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
                                if !feedDetail.description.isEmpty {
                                    Text(feedDetail.description)
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
                                    ForEach(feedDetail.challengeTags, id: \.self) { tag in
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
                .animation(.easeOut(duration: 0.4), value: viewModel.isLoading)
            }
            .task {
                await viewModel.loadFeedDetail()
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
        
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.localizedString(for: feedDetail.createdAt, relativeTo: Date())
    }
    
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
                    primary: PopupAction(title: "신고하기") {
                        Task {
                            let success = await viewModel.handleReport()
                            await MainActor.run {
                                viewModel.dismissPopup()
                                if success {
                                    toastManager.show(
                                        iconName: "toastWarningIcon",
                                        message: "신고가 접수되었습니다"
                                    )
                                } else {
                                    toastManager.show(
                                        iconName: "toastWarningIcon",
                                        message: "신고 처리 중 오류가 발생했습니다"
                                    )
                                }
                            }
                        }
                    },
                    secondary: PopupAction(title: "취소") {
                        viewModel.dismissPopup()
                    }
                )
            }
        }
    }
}
