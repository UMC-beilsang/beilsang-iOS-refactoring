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

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @StateObject private var keyboard = KeyboardResponder()
    @Environment(\.dismiss) private var dismiss
    
    init(container: ChallengeContainer) {
        _viewModel = StateObject(wrappedValue: container.homeViewModel)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Header(type: .primary(onNotification: {}, onSearch: {}))
                    
                    Spacer()
                        .frame(height: 20)
                    
                    HomeMainCardCrousel()
                        .padding(.horizontal, 24)
                    
                    Spacer()
                        .frame(height: 24)
                    
                    HomeCategoryScrollView(onCategoryTapped: {_ in })
                    
                    Spacer()
                        .frame(height: 20)
                    
                    Rectangle()
                        .fill(ColorSystem.labelNormalDisable)
                        .frame(height: 8)
                    
                    HomeMenuHeader(title: "참여 중인 챌린지",
                                   showAllButton: viewModel.activeChallenges.count > 2,
                                   onShowAllTapped: {})
                        .padding(.horizontal, 24)

                    if viewModel.activeChallenges.isEmpty {
                        VStack(spacing: 12) {
                            Text("현재 참여중인 챌린지가 없어요.")
                                .fontStyle(Fonts.body1SemiBold)
                                .foregroundStyle(ColorSystem.labelNormalNormal)
                                .padding(.top, 36)
                            
                            ActiveButton(title: "챌린지 둘러보기", action: {})
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 14) {
                                ForEach(viewModel.activeChallenges) { challenge in
                                    ChallengeItemView(
                                        challengeTitle: challenge.title,
                                        challengeImage: Image(challenge.thumbnailImageUrl ?? "", bundle: .designSystem),
                                        style: .progress(challenge.progress)
                                    ) {
                                        print("👉 tapped \(challenge.title)")
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    
                    HomeMenuHeader(title: "오늘의 추천 챌린지",
                                   showAllButton: viewModel.recommendedChallenges.count > 2,
                                   onShowAllTapped: {})
                        .padding(.horizontal, 24)
                    
                    if viewModel.recommendedChallenges.isEmpty {
                        VStack(spacing: 12) {
                            Text("오늘은 추천 챌린지가 없어요")
                                .fontStyle(Fonts.body1SemiBold)
                                .foregroundStyle(ColorSystem.labelNormalNormal)
                                .padding(.top, 36)
                            
                            ActiveButton(title: "다른 챌린지 둘러보기", action: {})
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 14) {
                                ForEach(viewModel.recommendedChallenges) { challenge in
                                    ChallengeItemView(
                                        challengeTitle: challenge.title,
                                        challengeImage: Image(challenge.thumbnailImageUrl ?? "", bundle: .designSystem),
                                        style: .participants(current: challenge.currentParticipants)
                                    ) {
                                        print("👉 tapped \(challenge.title)")
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
                                    
                                }
                            )
                            
                            Spacer()
                        }
                    }
                }
                
                Spacer()
                    .frame(minHeight: 180)
            }
            .padding(.bottom, keyboard.currentHeight)
            .scrollBounceBehavior(.basedOnSize)
        }
        .ignoresSafeArea(edges: .bottom)
        .task {
            await viewModel.loadChallenges()
        }
        
    }
}
