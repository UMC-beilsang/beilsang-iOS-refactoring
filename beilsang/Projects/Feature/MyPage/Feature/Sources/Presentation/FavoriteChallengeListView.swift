//
//  FavoriteChallengeListView.swift
//  MyPageFeature
//
//  Created by Seyoung Park on 11/28/25.
//

import SwiftUI
import UIComponentsShared
import DesignSystemShared
import ModelsShared
import NavigationShared

public struct FavoriteChallengeListView<ChallengeDetailView: View>: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: FavoriteChallengeListViewModel
    
    // 네비게이션 경로
    @State private var navigationPath: [Int] = []
    
    // ChallengeDetailView 생성 클로저 (외부에서 주입)
    @ViewBuilder let challengeDetailViewBuilder: (Int) -> ChallengeDetailView
    
    // 카테고리 상태
    @State private var selectedCategory: Keyword = .all
    
    public init(
        viewModel: FavoriteChallengeListViewModel,
        @ViewBuilder challengeDetailViewBuilder: @escaping (Int) -> ChallengeDetailView
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.challengeDetailViewBuilder = challengeDetailViewBuilder
    }
    
    public var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(alignment: .leading, spacing: 0) {
                // 헤더
                Header(type: .secondary(
                    title: "찜한 챌린지",
                    onBack: { dismiss() }
                ))
                
                // 카테고리 필터
                categoryFilter
                
                // Divider
                Rectangle()
                    .fill(ColorSystem.labelNormalDisable)
                    .frame(height: 8)
                
                // 콘텐츠
                ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("찜한 챌린지")
                        .fontStyle(.heading2Bold)
                        .foregroundStyle(ColorSystem.labelNormalStrong)
                        .padding(.horizontal, 24)
                        .padding(.top, 32)
                    
                    if viewModel.isLoading && viewModel.challenges.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                    } else if viewModel.challenges.isEmpty {
                        emptyStateView
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.challenges) { challenge in
                                ChallengeItemView(
                                    title: challenge.title,
                                    imageUrl: challenge.thumbnailImageUrl ?? "",
                                    style: .progressList(
                                        progress: "\(Int(challenge.progress))%",
                                        author: challenge.author.isEmpty ? "익명" : challenge.author
                                    ),
                                    isRecruitmentClosed: challenge.isRecruitmentClosed,
                                    onTapped: {
                                        // NavigationStack으로 상세 화면 표시
                                        navigationPath.append(challenge.id)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    Spacer().frame(height: 100)
                }
            }
            }
            .background(ColorSystem.backgroundNormalNormal)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Int.self) { challengeId in
                challengeDetailViewBuilder(challengeId)
            }
        }
        .onChange(of: selectedCategory) { _, _ in
            Task {
                await viewModel.fetchFavoriteChallenges(category: selectedCategory, reset: true)
            }
        }
        .task {
            await viewModel.fetchFavoriteChallenges(category: selectedCategory, reset: true)
        }
    }
    
    // MARK: - Category Filter
    private var categoryFilter: some View {
        CategoryGridView(
            layout: .singleRow,
            selectedKeyword: selectedCategory
        ) { keyword in
            selectedCategory = keyword
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Text("찜한 챌린지가 없어요.")
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
}

