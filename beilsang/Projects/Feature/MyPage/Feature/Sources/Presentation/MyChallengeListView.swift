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
            VStack(alignment: .leading, spacing: 0) {
                // 헤더
                Header(type: .secondary(
                    title: "나의 챌린지",
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
                    ZStack {
                        if viewModel.isInitialLoading {
                            MyChallengeListSkeletonView()
                                .transition(.opacity)
                        } else {
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
                            .transition(.opacity)
                        }
                    }
                    .animation(.easeOut(duration: 0.4), value: viewModel.isInitialLoading)
                }
            }
            .background(ColorSystem.backgroundNormalNormal)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Int.self) { challengeId in
                challengeDetailViewBuilder(challengeId)
            }
        }
        .onAppear {
            // 이미 데이터가 있으면 로딩 상태 즉시 해제 (깜빡임 방지)
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
                showSkeleton: true
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
                // TODO: 챌린지 목록으로 이동
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

