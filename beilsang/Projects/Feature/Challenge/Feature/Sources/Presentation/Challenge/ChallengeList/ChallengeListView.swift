//
//  ChallengeListView.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/30/25.
//

import SwiftUI
import UIComponentsShared
import DesignSystemShared
import ModelsShared
import ChallengeDomain

public struct ChallengeListView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ChallengeListViewModel
    @EnvironmentObject var coordinator: ChallengeCoordinator
    
    let category: Keyword
    
    public init(viewModel: ChallengeListViewModel, category: Keyword) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.category = category
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Header(type: .tertiaryReport(
                title: category.title,
                onBack: { dismiss() },
                onOption: {}
            ))
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    ZStack {
                        if viewModel.isLoading {
                            ChallengeListSkeletonView()
                                .transition(.opacity)
                        }
                        
                        if !viewModel.isLoading {
                            VStack(alignment: .leading, spacing: 0) {
                                bannerSection
                                    .padding(.top, 20)
                                    .padding(.bottom, 32)
                                
                                challengeListSection
                            }
                            .transition(.opacity)
                        }
                    }
                    .animation(.easeOut(duration: 0.4), value: viewModel.isLoading)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .scrollBounceBehavior(.basedOnSize)
            .refreshable {
                await viewModel.fetchChallenges(for: category, showSkeleton: true)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            // 이미 데이터가 있으면 로딩 상태 즉시 해제 (깜빡임 방지)
            if !viewModel.items.isEmpty {
                viewModel.isLoading = false
            }
        }
        .task {
            // 초기 로딩 (데이터가 비어있을 때만)
            if viewModel.items.isEmpty {
                await viewModel.fetchChallenges(for: category, showSkeleton: true)
            }
        }
    }
    
    private var bannerSection: some View {
        Button(action: {
            coordinator.navigateToCreate()
        }) {
            Image("listBannerIcon", bundle: .designSystem)
                .resizable()
                .scaledToFill()
                .frame(height: UIScreen.main.bounds.height * 0.1)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var challengeListSection: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.items) { item in
                ChallengeItemView(
                    title: item.title,
                    imageUrl: item.thumbnailImageUrl,
                    style: .progressList(
                        progress: item.progressText,
                        author: item.author ?? "익명"
                    ),
                    isRecruitmentClosed: item.isRecruitmentClosed
                ) {
                    coordinator.navigateToDetail(id: item.id)
                }
            }
        }
    }
}
