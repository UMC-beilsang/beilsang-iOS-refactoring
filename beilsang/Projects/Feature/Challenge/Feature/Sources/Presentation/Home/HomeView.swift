//
//  HomeView.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/1/25.
//

import SwiftUI
import UIComponentsShared
import ModelsShared
import DesignSystemShared
import UtilityShared
import ChallengeDomain

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @ObservedObject private var router: ChallengeRouter
    @StateObject private var keyboard = KeyboardResponder()
    
    init(container: ChallengeContainer, router: ChallengeRouter) {
        _viewModel = StateObject(wrappedValue: container.homeViewModel)
        self._router = ObservedObject(initialValue: router)
    }
    
    var body: some View {
        NavigationStack(path: $router.path) {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Header(type: .primary(onNotification: {}, onSearch: {}))
                        
                        Spacer().frame(height: 20)
                        
                        HomeMainCardCrousel()
                            .padding(.horizontal, 24)
                        
                        Spacer().frame(height: 24)
                        
                        HomeCategoryScrollView(onCategoryTapped: { category in
                            router.navigateToChallengeList(category: category)
                        })
                        
                        Spacer().frame(height: 20)
                        
                        Rectangle()
                            .fill(ColorSystem.labelNormalDisable)
                            .frame(height: 8)
                        
                        // 참여 중인 챌린지
                        activeChallengesSection
                        
                        // 추천 챌린지
                        recommendedChallengesSection
                    }
                    
                    Spacer().frame(minHeight: 180)
                }
                .padding(.bottom, keyboard.currentHeight)
                .scrollBounceBehavior(.basedOnSize)
            }
            .navigationDestination(for: ChallengeRoute.self) { route in
                switch route {
                case .challengeList(let category):
                    ChallengeListView(
                        category: category,
                        repository: MockChallengeRepository(),
                        onChallengeSelected: { challengeId in
                            router.navigateToDetail(id: challengeId)
                        },
                        onBannerTapped: {
                            router.navigateToCreate()
                        }
                    )
                    
                case .challengeDetail(let id):
                    ChallengeDetailView(id: id, repository: MockChallengeRepository())
                    
                case .challengeCreate:
                    ChallengeAddView(
                        viewModel: ChallengeAddViewModel(repository: MockChallengeRepository())
                    )
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .task {
                await viewModel.loadChallenges()
            }
        }
    }
    
    // MARK: - Active Challenges Section
    private var activeChallengesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HomeMenuHeader(
                title: "참여 중인 챌린지",
                showAllButton: viewModel.activeChallenges.count > 2,
                onShowAllTapped: {
                    router.navigateToChallengeList(category: .all)
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
                        router.navigateToChallengeList(category: .all)
                    })
                }
                .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(viewModel.activeChallenges) { challenge in
                            ChallengeItemView(
                                title: challenge.title,
                                imageUrl: challenge.thumbnailImageUrl ?? "",
                                style: .progressGrid(String(format: "%.0f%%", challenge.progress))
                            ) {
                                router.navigateToDetail(id: challenge.id)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
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
                    router.navigateToChallengeList(category: .all)
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
                        router.navigateToChallengeList(category: .all)
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
                                style: .participantsGrid("\(challenge.currentParticipants)명")
                            ) {
                                router.navigateToDetail(id: challenge.id)
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
                            router.navigateToChallengeList(category: .all)
                        }
                    )
                    
                    Spacer()
                }
            }
        }
    }
}
