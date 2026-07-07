//
//  HomeView.swift
//  ChallengeFeature
//
// Created by Park Seyoung on 8/28/25.
//

import SwiftUI
import UIComponentsShared
import ModelsShared
import DesignSystemShared
import UtilityShared
import NavigationShared

public struct HomeView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var coordinator: ChallengeCoordinator
    
    @StateObject private var viewModel: HomeViewModel
    
    public init(container: ChallengeContainer) {
        _viewModel = StateObject(wrappedValue: container.homeViewModel)
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Header(type: .primary(
                        onNotification: {
                            coordinator.presentNotification()
                        },
                        onSearch: {
                            coordinator.presentSearch()
                        }
                    ))
                    
                    ZStack {
                        if viewModel.isLoading {
                            skeletonContentView
                                .transition(.opacity)
                        }
                        
                        if !viewModel.isLoading {
                            contentView
                                .transition(.opacity)
                        }
                    }
                    .animation(.easeOut(duration: 0.2), value: viewModel.isLoading)
                }
                
                Spacer().frame(minHeight: 180)
            }
            .scrollBounceBehavior(.basedOnSize)
            .refreshable {
                await viewModel.loadChallenges(showSkeleton: false)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if !viewModel.activeChallenges.isEmpty || !viewModel.recommendedChallenges.isEmpty {
                viewModel.isLoading = false
                Task { await viewModel.loadChallenges(showSkeleton: false) }
            }
        }
        .task {
            if viewModel.activeChallenges.isEmpty && viewModel.recommendedChallenges.isEmpty {
                await viewModel.loadChallenges(showSkeleton: true)
            }
        }
    }
    
    // MARK: - Content View
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 20)
            
            HomeMainCardCrousel()
                .padding(.horizontal, 24)
            
            Spacer().frame(height: 24)
            
            CategoryGridView(layout: .twoRow) { keyword in
                coordinator.navigateToChallengeList(category: keyword)
            }
            
            Spacer().frame(height: 20)
            
            Rectangle()
                .fill(ColorSystem.labelNormalDisable)
                .frame(height: 8)
            
            activeChallengesSection
            recommendedChallengesSection
        }
    }
    
    // MARK: - Skeleton Content View
    private var skeletonContentView: some View {
        HomeSkeletonView()
    }
    
    // MARK: - Active Challenges Section
    private var activeChallengesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HomeMenuHeader(
                title: "참여 중인 챌린지",
                showAllButton: viewModel.activeChallenges.count > 2,
                onShowAllTapped: {
                    coordinator.navigateToActiveList()
                }
            )
            .padding(.horizontal, 24)
            
            if viewModel.activeChallenges.isEmpty {
                VStack(spacing: 12) {
                    Text("현재 참여중인 챌린지가 없어요.")
                        .fontStyle(Fonts.body1SemiBold)
                        .foregroundStyle(ColorSystem.labelNormalNormal)
                        .padding(.top, 36)
                    
                    ActiveButton(title: "챌린지 둘러보기", action: {
                        coordinator.navigateToChallengeList(category: .all)
                    })
                }
                .frame(maxWidth: .infinity, alignment: .center)
            } else {
                HStack(spacing: 14) {
                    ForEach(viewModel.activeChallenges.prefix(2)) { challenge in
                        ChallengeItemView(
                            title: challenge.title,
                            imageUrl: challenge.thumbnailImageUrl ?? "",
                            style: .progressGrid(String(format: "%.0f%%", (challenge.progress ?? 0.0) * 100)),
                            isRecruitmentClosed: challenge.isRecruitmentClosed
                        ) {
                            coordinator.navigateToDetail(id: challenge.id)
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
    
    // MARK: - Recommended Challenges Section
    private var recommendedChallengesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HomeMenuHeader(
                title: "오늘의 추천 챌린지",
                showAllButton: viewModel.recommendedChallenges.count > 2,
                onShowAllTapped: {
                    coordinator.navigateToChallengeList(category: .all)
                }
            )
            .padding(.horizontal, 24)
            
            if viewModel.recommendedChallenges.isEmpty {
                VStack(spacing: 12) {
                    Text("오늘은 추천 챌린지가 없어요")
                        .fontStyle(Fonts.body1SemiBold)
                        .foregroundStyle(ColorSystem.labelNormalNormal)
                        .padding(.top, 36)
                    
                    ActiveButton(title: "다른 챌린지 둘러보기", action: {
                        coordinator.navigateToChallengeList(category: .all)
                    })
                }
                .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(viewModel.recommendedChallenges) { challenge in
                            ChallengeItemView(
                                title: challenge.title,
                                imageUrl: challenge.thumbnailImageUrl ?? "",
                                style: .participantsGrid("\(challenge.currentParticipants)명"),
                                isRecruitmentClosed: challenge.isRecruitmentClosed
                            ) {
                                coordinator.navigateToDetail(id: challenge.id)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer().frame(height: 40)
                
                HStack {
                    Spacer()
                    
                    ActiveButton(
                        title: "전체 챌린지 보기",
                        action: {
                            coordinator.navigateToChallengeList(category: .all)
                        }
                    )
                    
                    Spacer()
                }
            }
        }
    }
}
