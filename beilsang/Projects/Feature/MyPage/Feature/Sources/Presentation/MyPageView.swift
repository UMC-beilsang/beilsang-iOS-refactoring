//
//  MyPageView.swift
//  MyPageFeature
//
//  Created by Seyoung Park on 11/26/25.
//

import SwiftUI
import UIComponentsShared
import ModelsShared
import DesignSystemShared
import UtilityShared
import NavigationShared

public struct MyPageView: View {
    @StateObject private var viewModel: MyPageViewModel
    @EnvironmentObject var coordinator: MyPageCoordinator
    @Environment(\.challengePresentationCoordinator) var challengePresentationCoordinator
    
    public init(viewModel: MyPageViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // 헤더
                Header(type: .primaryTitle(
                    title: "마이페이지",
                    onNotification: {
                        challengePresentationCoordinator?.presentNotification()
                    },
                    onSearch: {
                        challengePresentationCoordinator?.presentSearch()
                    }
                ))
                
                ZStack {
                    if viewModel.isInitialLoading {
                        MyPageSkeletonView()
                            .transition(.opacity)
                    } else {
                        VStack(alignment: .leading, spacing: 0) {
                            // 프로필 섹션
                            profileSection
                            
                            
                            //Divider
                            Rectangle()
                                .fill(ColorSystem.labelNormalDisable)
                                .frame(height: 8)
                            
                            // 나의 챌린지 섹션
                            myChallengesSection
                            
                            // 나의 챌린지 피드 섹션
                            myFeedsSection
                            
                            Spacer().frame(height: 100)
                        }
                        .transition(.opacity)
                    }
                }
                .animation(.easeOut(duration: 0.4), value: viewModel.isInitialLoading)
            }
        }
        .onAppear {
            // 이미 데이터가 있으면 로딩 상태 즉시 해제 (깜빡임 방지)
            if viewModel.userProfile != nil || !viewModel.myFeeds.isEmpty {
                viewModel.isInitialLoading = false
            }
        }
        .task {
            // 초기 로딩 (데이터가 비어있을 때만)
            if viewModel.userProfile == nil && viewModel.myFeeds.isEmpty {
                await viewModel.loadUserProfile(showSkeleton: true)
                await viewModel.loadMyFeeds(reset: true, showSkeleton: true)
            }
        }
        .refreshable {
            await viewModel.loadUserProfile(showSkeleton: true)
            await viewModel.loadMyFeeds(reset: true, showSkeleton: true)
        }
    }
    
    // MARK: - Profile Section
    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 28) {
            // 닉네임
            Text("안녕하세요, \(viewModel.nickname)")
                .fontStyle(.heading2Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)
            
            HStack(alignment: .center) {
                // 프로필 이미지
                if let imageUrl = viewModel.profileImageUrl,
                   let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Image("profilePlaceholderImage", bundle: .designSystem)
                            .resizable()
                            .scaledToFill()
                    }
                    .frame(width: 88, height: 88)
                    .clipShape(Circle())
                } else {
                    Image("profilePlaceholderImage", bundle: .designSystem)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 88, height: 88)
                        .clipShape(Circle())
                }
                
                Spacer()
                
                // 통계
                HStack(spacing: 0) {
                    Button {
                        coordinator.presentMyFeedList()
                    } label: {
                        statItem(title: "피드", value: viewModel.feedCount)
                            .frame(maxWidth: .infinity)
                    }
                    
                    Button {
                        coordinator.presentMyChallengeList(tabIndex: 1) // 달성 탭
                    } label: {
                        statItem(title: "달성", value: viewModel.successChallengeCount)
                            .frame(maxWidth: .infinity)
                    }
                    
                    Button {
                        coordinator.presentMyChallengeList(tabIndex: 2) // 실패 탭
                    } label: {
                        statItem(title: "실패", value: viewModel.failedChallengeCount)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 12) {
                if let motto = viewModel.motto {
                    MottoDisplayView(
                        title: motto.title,
                        iconName: motto.iconName
                    )
                }
                
                // Profile Edit Button
                HStack {
                    Spacer()
                    
                    Button {
                        coordinator.navigateToProfileEdit()
                    } label: {
                        HStack(spacing: 0) {
                            Text("프로필 수정하기")
                                .fontStyle(.detail1Medium)
                                .foregroundStyle(ColorSystem.labelNormalBasic)
                            
                            Image("caretIcon", bundle: .designSystem)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 12, height: 12)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 28)
    }
    
    private func statItem(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .fontStyle(.body1Medium)
                .foregroundStyle(ColorSystem.labelNormalNormal)
            Text(value)
                .fontStyle(.heading3Bold)
                .foregroundStyle(ColorSystem.primaryStrong)
        }
    }
    
    // MARK: - My Challenges Section
    private var myChallengesSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .center) {
                Text("나의 챌린지")
                    .fontStyle(.heading2Bold)
                    .foregroundStyle(ColorSystem.labelNormalStrong)
                
                Spacer()
                
                Button {
                    coordinator.presentMyChallengeList(tabIndex: 0)
                } label: {
                    HStack(spacing: 0) {
                        Text("전체보기")
                            .fontStyle(.detail1Medium)
                            .foregroundStyle(ColorSystem.labelNormalBasic)
                        
                        Image("caretIcon", bundle: .designSystem)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                    }
                }
            }
            
            // 챌린지 통계 카드
            challengeStatsCard
        }
        .padding(.horizontal, 24)
        .padding(.top, 32)
    }
    
    private var challengeStatsCard: some View {
        HStack(spacing: 6) {
            statCardItem(
                iconName: "challengeSuccessIcon",
                title: "전체 챌린지",
                value: viewModel.ongoingChallengeCount,
                onTap: { coordinator.presentMyChallengeList(tabIndex: 0) }
            )
            
            verticalDivider
            
            statCardItem(
                iconName: "starColoredIcon",
                title: "찜한 챌린지",
                value: viewModel.likesCount,
                onTap: { coordinator.presentFavoriteChallengeList() }
            )
            
            verticalDivider
            
            statCardItem(
                iconName: "pointIcon",
                title: "내 포인트",
                value: viewModel.totalPoint,
                onTap: { coordinator.navigateToPoint() }
            )
            
            verticalDivider
            
            statCardItem(
                iconName: "leafIcon",
                title: "내 배지",
                value: viewModel.badgeCount,
                onTap: { coordinator.navigateToBadge() }
            )
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(ColorSystem.labelNormalDisable)
        .cornerRadius(20)
    }
    
    private func statCardItem(iconName: String, title: String, value: String, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Image(iconName, bundle: .designSystem)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .fontStyle(.detail1Medium)
                    .foregroundStyle(ColorSystem.labelNormalNormal)
                
                Text(value)
                    .fontStyle(.body2SemiBold)
                    .foregroundStyle(ColorSystem.primaryStrong)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private var verticalDivider: some View {
        Rectangle()
            .fill(ColorSystem.lineNormal)
            .frame(width: 1, height: 60)
    }
    
    // MARK: - My Feeds Section
    private var myFeedsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("나의 챌린지 피드")
                    .fontStyle(.heading2Bold)
                    .foregroundStyle(ColorSystem.labelNormalStrong)
                
                Spacer()
                
                Button {
                    coordinator.presentMyFeedList()
                } label: {
                    HStack(spacing: 0) {
                        Text("전체보기")
                            .fontStyle(.detail1Medium)
                            .foregroundStyle(ColorSystem.labelNormalBasic)
                        
                        Image("caretIcon", bundle: .designSystem)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(.horizontal, 24)
            
            // 피드 그리드
            if viewModel.myFeeds.isEmpty {
                if viewModel.isFeedsLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                } else {
                    emptyFeedView
                }
            } else {
                feedGrid
            }
        }
        .padding(.top, 32)
        .padding(.bottom, 100)
    }
    
    // MARK: - Empty Feed View
    private var emptyFeedView: some View {
        VStack(spacing: 12) {
            Text("아직 인증한 챌린지가 없어요")
                .fontStyle(.body1SemiBold)
                .foregroundStyle(ColorSystem.labelNormalNormal)
                .padding(.top, 36)
            
            ActiveButton(title: "챌린지 둘러보기") {
                // TODO: 챌린지 목록으로 이동
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, 24)
    }
    
    // MARK: - Feed Grid
    @ViewBuilder
    private var feedGrid: some View {
        VStack(spacing: 0) {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 14),
                    GridItem(.flexible(), spacing: 14)
                ],
                spacing: 14
            ) {
                ForEach(viewModel.myFeeds, id: \.feedId) { feed in
                    FeedThumbnailCard(
                        imageUrl: feed.feedUrl,
                        isMyFeed: false
                    ) {
                        challengePresentationCoordinator?.presentFeed(id: feed.feedId)
                    }
                    .onAppear {
                        // 마지막 아이템에 도달하면 더 로드
                        if feed.feedId == viewModel.myFeeds.last?.feedId,
                           viewModel.hasMoreFeeds {
                            Task {
                                await viewModel.loadMyFeeds()
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            
            if viewModel.isFeedsLoading && !viewModel.myFeeds.isEmpty {
                ProgressView()
                    .padding(.top, 16)
            }
        }
    }
}

