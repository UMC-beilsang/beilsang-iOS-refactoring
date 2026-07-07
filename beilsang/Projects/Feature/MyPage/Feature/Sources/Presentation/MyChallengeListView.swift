//
//  MyChallengeListView.swift
//  MyPageFeature
//
//  Created by Seyoung Park on 11/28/25.
//

import SwiftUI
import UIComponentsShared
import DesignSystemShared
import ModelsShared
import NavigationShared

public struct MyChallengeListView<ChallengeDetailView: View>: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.challengePresentationCoordinator) private var challengePresentationCoordinator
    @StateObject private var viewModel: MyChallengeListViewModel
    
    // 네비게이션 경로
    @State private var navigationPath: [Int] = []
    
    // ChallengeDetailView 생성 클로저 (외부에서 주입)
    @ViewBuilder let challengeDetailViewBuilder: (Int) -> ChallengeDetailView
    
    // 탭 상태
    @State private var selectedTab: Int
    private let tabs = ["참여", "달성", "실패"]
    
    // 카테고리 상태
    @State private var selectedCategory: Keyword = .all
    
    public init(
        viewModel: MyChallengeListViewModel,
        initialTab: Int = 0,
        @ViewBuilder challengeDetailViewBuilder: @escaping (Int) -> ChallengeDetailView
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _selectedTab = State(initialValue: initialTab)
        self.challengeDetailViewBuilder = challengeDetailViewBuilder
    }
    
    public var body: some View {
        NavigationStack(path: $navigationPath) {
            contentView
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: Int.self) { challengeId in
                    challengeDetailViewBuilder(challengeId)
                }
        }
        .onAppear {
            if !viewModel.challenges.isEmpty {
                viewModel.isInitialLoading = false
            }
        }
        .onChange(of: selectedTab) { _, _ in
            Task {
                await viewModel.fetchChallenges(
                    tabIndex: selectedTab,
                    category: selectedCategory,
                    reset: true,
                    showSkeleton: true
                )
            }
        }
        .onChange(of: selectedCategory) { _, _ in
            Task {
                await viewModel.fetchChallenges(
                    tabIndex: selectedTab,
                    category: selectedCategory,
                    reset: true,
                    showSkeleton: true
                )
            }
        }
        .task {
            if viewModel.challenges.isEmpty {
                await viewModel.fetchChallenges(
                    tabIndex: selectedTab,
                    category: selectedCategory,
                    reset: true,
                    showSkeleton: true
                )
            }
        }
        .refreshable {
            await viewModel.fetchChallenges(
                tabIndex: selectedTab,
                category: selectedCategory,
                reset: true,
                showSkeleton: false
            )
        }
    }
    
    // MARK: - Content View
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Header(type: .secondary(
                title: "나의 챌린지",
                onBack: { dismiss() }
            ))
            
            tabBar
            categoryFilter
            
            Rectangle()
                .fill(ColorSystem.labelNormalDisable)
                .frame(height: 8)
            
            challengeListContent
        }
        .background(ColorSystem.backgroundNormalNormal)
    }
    
    // MARK: - Challenge List Content
    private var challengeListContent: some View {
        ScrollView {
            ZStack {
                if viewModel.isInitialLoading {
                    MyChallengeListSkeletonView()
                        .transition(.opacity)
                } else {
                    challengeListSection
                        .transition(.opacity)
                }
            }
            .animation(.easeOut(duration: 0.2), value: viewModel.isInitialLoading)
        }
    }
    
    // MARK: - Challenge List Section
    private var challengeListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(sectionTitle)
                .fontStyle(.heading2Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)
                .padding(.horizontal, 24)
                .padding(.top, 32)
            
            if viewModel.challenges.isEmpty {
                emptyStateView
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.challenges) { challenge in
                        ChallengeItemView(
                            title: challenge.title,
                            imageUrl: challenge.thumbnailImageUrl ?? "",
                            style: .progressList(
                                progress: "0.0%",
                                author: "30명 참여"
                            ),
                            isRecruitmentClosed: challenge.isRecruitmentClosed,
                            onTapped: {
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
        case 0: return "참여 중인 챌린지"
        case 1: return "달성한 챌린지"
        case 2: return "실패한 챌린지"
        default: return "챌린지"
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
                dismiss()
                challengePresentationCoordinator?.browseChallenges()
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, 24)
    }
    
    private var emptyStateMessage: String {
        switch selectedTab {
        case 0: return "현재 참여중인 챌린지가 없어요."
        case 1: return "달성한 챌린지가 없어요."
        case 2: return "실패한 챌린지가 없어요."
        default: return "챌린지가 없어요."
        }
    }
}

