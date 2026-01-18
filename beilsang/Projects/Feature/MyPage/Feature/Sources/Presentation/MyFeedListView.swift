//
//  MyFeedListView.swift
//  MyPageFeature
//
//  Created by Seyoung Park on 11/28/25.
//

import SwiftUI
import UIComponentsShared
import DesignSystemShared
import ModelsShared
import NavigationShared

public struct MyFeedListView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: MyFeedListViewModel
    
    // 네비게이션 경로
    @State private var navigationPath: [Int] = []
    
    // ChallengeFeedDetailView 생성 클로저 (외부에서 주입)
    let feedDetailViewBuilder: (Int) -> AnyView
    
    // 탭 상태
    @State private var selectedTab: Int = 0
    private let tabs = ["참여", "달성", "실패"]
    
    // 카테고리 상태
    @State private var selectedCategory: Keyword = .all
    
    public init(
        viewModel: MyFeedListViewModel,
        feedDetailViewBuilder: @escaping (Int) -> AnyView
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.feedDetailViewBuilder = feedDetailViewBuilder
    }
    
    public var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(alignment: .leading, spacing: 0) {
                // 헤더
                Header(type: .secondary(
                    title: "나의 챌린지 피드",
                    onBack: { dismiss() }
                ))
                
                // 탭 바
                tabBar
                
                // 카테고리 필터
                categoryFilter
                
                // Divider
                Rectangle()
                    .fill(ColorSystem.labelNormalDisable)
                    .frame(height: 8)
                
                // 콘텐츠
                ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(sectionTitle)
                        .fontStyle(.heading2Bold)
                        .foregroundStyle(ColorSystem.labelNormalStrong)
                        .padding(.horizontal, 24)
                        .padding(.top, 32)
                    
                    if viewModel.isLoading && viewModel.feeds.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                    } else if viewModel.feeds.isEmpty {
                        emptyStateView
                    } else {
                        feedGrid
                    }
                    
                    Spacer().frame(height: 100)
                }
            }
            }
            .background(ColorSystem.backgroundNormalNormal)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Int.self) { feedId in
                feedDetailViewBuilder(feedId)
            }
        }
        .onChange(of: selectedTab) { _, _ in
            Task {
                await viewModel.fetchFeeds(
                    tabIndex: selectedTab,
                    category: selectedCategory,
                    reset: true
                )
            }
        }
        .onChange(of: selectedCategory) { _, _ in
            Task {
                await viewModel.fetchFeeds(
                    tabIndex: selectedTab,
                    category: selectedCategory,
                    reset: true
                )
            }
        }
        .task {
            await viewModel.fetchFeeds(
                tabIndex: selectedTab,
                category: selectedCategory,
                reset: true
            )
        }
    }
    
    // MARK: - Tab Bar
    private var tabBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(0..<tabs.count, id: \.self) { index in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = index
                        }
                    } label: {
                        Text(tabs[index])
                            .fontStyle(selectedTab == index ? .heading3Bold : .heading3SemiBold)
                            .foregroundStyle(selectedTab == index ? ColorSystem.primaryHeavy : ColorSystem.labelNormalBasic)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal, 24)
            
            // 화면 끝까지 이어지는 하단 배경 라인
            Rectangle()
                .fill(ColorSystem.lineNormal)
                .frame(height: 1)
                .padding(.horizontal, -24)
        }
        .background(ColorSystem.backgroundNormalNormal)
        .overlay(
            // 선택된 탭 위에만 primary 색상 라인 오버레이
            GeometryReader { geometry in
                let tabWidth = (geometry.size.width - 48) / CGFloat(tabs.count)
                let selectedTabX = 24 + tabWidth * CGFloat(selectedTab)
                
                Rectangle()
                    .fill(ColorSystem.primaryStrong)
                    .frame(width: tabWidth, height: 2)
                    .offset(x: selectedTabX, y: geometry.size.height - 2)
            }
        )
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
    
    // MARK: - Section Title
    private var sectionTitle: String {
        switch selectedTab {
        case 0: return "참여 중인 챌린지 피드"
        case 1: return "달성한 챌린지 피드"
        case 2: return "실패한 챌린지 피드"
        default: return "챌린지 피드"
        }
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
                ForEach(viewModel.feeds, id: \.feedId) { feed in
                    FeedThumbnailCard(
                        imageUrl: feed.feedUrl,
                        isMyFeed: true
                    ) {
                        // NavigationStack으로 피드 상세 화면 표시
                        navigationPath.append(feed.feedId)
                    }
                    .onAppear {
                        // 마지막 아이템에 도달하면 더 로드
                        if feed.feedId == viewModel.feeds.last?.feedId,
                           viewModel.hasNext {
                            Task {
                                await viewModel.fetchFeeds(
                                    tabIndex: selectedTab,
                                    category: selectedCategory,
                                    reset: false
                                )
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            
            if viewModel.isLoading && !viewModel.feeds.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Text(emptyStateMessage)
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
    
    private var emptyStateMessage: String {
        switch selectedTab {
        case 0: return "참여 중인 챌린지 피드가 없어요."
        case 1: return "달성한 챌린지 피드가 없어요."
        case 2: return "실패한 챌린지 피드가 없어요."
        default: return "챌린지 피드가 없어요."
        }
    }
}

