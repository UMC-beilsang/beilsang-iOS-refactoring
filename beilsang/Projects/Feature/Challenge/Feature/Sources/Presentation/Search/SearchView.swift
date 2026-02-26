//
//  SearchView.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 11/30/25.
//

import SwiftUI
import UIComponentsShared
import DesignSystemShared
import ModelsShared
import NavigationShared

public struct SearchView<ChallengeDetailView: View, FeedDetailView: View>: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: SearchViewModel
    @FocusState private var isSearchFocused: Bool?
    
    // 네비게이션 경로
    @State private var navigationPath: [Int] = []
    
    // ChallengeDetailView 생성 클로저 (외부에서 주입)
    @ViewBuilder let challengeDetailViewBuilder: (Int) -> ChallengeDetailView
    // ChallengeFeedDetailView 생성 클로저 (외부에서 주입)
    @ViewBuilder let feedDetailViewBuilder: (Int) -> FeedDetailView
    
    public init(
        viewModel: SearchViewModel,
        @ViewBuilder challengeDetailViewBuilder: @escaping (Int) -> ChallengeDetailView,
        @ViewBuilder feedDetailViewBuilder: @escaping (Int) -> FeedDetailView
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.challengeDetailViewBuilder = challengeDetailViewBuilder
        self.feedDetailViewBuilder = feedDetailViewBuilder
    }
    
    public var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(alignment: .leading, spacing: 0) {
                // 헤더
                searchHeader
                
                // 콘텐츠
                if viewModel.hasSearched {
                    searchResultsView
                } else {
                    recentSearchesView
                }
            }
            .background(ColorSystem.backgroundNormalNormal)
            .toolbar(.hidden, for: .navigationBar)
            .dismissKeyboardOnTap(focusedField: $isSearchFocused)
            .sheet(isPresented: $viewModel.showFilterSheet) {
                FilterBottomSheet(
                    selectedFilter: viewModel.selectedFilter,
                    onFilterSelected: { filter in
                        viewModel.applyFilter(filter)
                    }
                )
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
            }
            .navigationDestination(for: Int.self) { id in
                if viewModel.selectedTab == .challenge {
                    challengeDetailViewBuilder(id)
                } else {
                    feedDetailViewBuilder(id)
                }
            }
            .onAppear {
                DispatchQueue.main.async {
                    isSearchFocused = true
                }
                Task {
                    await viewModel.loadRecommendedChallenges()
                }
            }
        }
    }
    
    // MARK: - Search Header
    private var searchHeader: some View {
        HStack(spacing: 12) {
            Button {
                dismiss()
            } label: {
                Image("backIcon", bundle: .designSystem)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
            }
            
            HStack(spacing: 6) {
                ZStack(alignment: .leading) {
                    if viewModel.searchText.isEmpty {
                        Text("관심있는 챌린지를 검색해보세요")
                            .fontStyle(.body1Medium)
                            .foregroundStyle(ColorSystem.labelNormalBasic)
                    }
                    
                    TextField("", text: $viewModel.searchText)
                        .fontStyle(.body1Medium)
                        .foregroundStyle(ColorSystem.labelNormalNormal)
                        .focused($isSearchFocused, equals: true)
                        .onSubmit {
                            Task {
                                await viewModel.performSearch(query: viewModel.searchText)
                            }
                        }
                }
                
                Spacer()
                
                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                        isSearchFocused = true
                    } label: {
                        Image("clearIcon", bundle: .designSystem)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    }
                    .buttonStyle(.plain)
                }
                
                Button {
                    isSearchFocused = nil
                    Task {
                        await viewModel.performSearch(query: viewModel.searchText)
                    }
                } label: {
                    Image(isSearchFocused == true ? "searchIconFocused" : "searchIcon", bundle: .designSystem)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .frame(height: 44)
            .background(ColorSystem.backgroundNormalAlternative)
            .cornerRadius(999)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
        .background(ColorSystem.backgroundNormalNormal)
    }
    
    // MARK: - Recent Searches
    private var recentSearchesView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // 최근 검색어 헤더
                HStack {
                    Text("최근 검색어")
                        .fontStyle(.heading3Bold)
                        .foregroundStyle(ColorSystem.labelNormalNormal)
                    
                    Spacer()
                    
                    if !viewModel.recentSearches.isEmpty {
                        Button {
                            viewModel.clearAllRecentSearches()
                        } label: {
                            Text("전체 삭제")
                                .fontStyle(.detail1Medium)
                                .foregroundStyle(ColorSystem.labelNormalBasic)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)
                
                if viewModel.recentSearches.isEmpty {
                    // 빈 상태
                    HStack {
                        Text("최근 검색 내역이 없습니다")
                            .fontStyle(.detail1Medium)
                            .foregroundStyle(ColorSystem.labelNormalBasic)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)
                    .padding(.horizontal, 24)
                    
                } else {
                    // 최근 검색어 리스트
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.recentSearches, id: \.self) { search in
                                HStack(spacing: 4) {
                                    Button {
                                        viewModel.searchText = search
                                        Task {
                                            await viewModel.performSearch(query: search)
                                        }
                                    } label: {
                                        Text(search)
                                            .fontStyle(.body2Medium)
                                            .foregroundStyle(ColorSystem.primaryStrong)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    Button {
                                        viewModel.removeRecentSearch(search)
                                    } label: {
                                        Image("deleteIcon", bundle: .designSystem)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 12, height: 12)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(ColorSystem.labelNormalDisable)
                                .cornerRadius(999)
                                .contentShape(Rectangle())
                            }
                        }
                        .padding(.top, 16)
                        .padding(.horizontal, 24)
                    }
                }
            }
        }
    }
    
    // MARK: - Search Results
    private var searchResultsView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 탭 바
            tabBar
            
            // 챌린지 탭일 때만 필터 & 체크박스 표시
            if viewModel.selectedTab == .challenge {
                filterAndCheckboxSection
            }
            
            // 선택된 필터 태그
            if !viewModel.selectedFilters.isEmpty {
                filterTagsSection
            }
            
            ZStack {
                if viewModel.isLoading {
                    SearchResultsSkeletonView(
                        style: viewModel.selectedTab == .challenge ? .challenge : .feed
                    )
                    .transition(.opacity)
                }
                
                if !viewModel.isLoading {
                    if viewModel.currentTabIsEmpty {
                        ScrollView {
                            EmptySearchResultView(searchText: viewModel.searchText)
                                .padding(.horizontal, 24)
                        }
                        .transition(.opacity)
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 0) {
                                // 결과 리스트
                                if viewModel.selectedTab == .challenge {
                                    challengeResultsSection
                                } else {
                                    feedResultsSection
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                            .padding(.bottom, 40)
                        }
                        .transition(.opacity)
                    }
                }
            }
            .animation(.easeOut(duration: 0.4), value: viewModel.isLoading)
        }
    }
    
    // MARK: - Filter & Checkbox Section
    private var filterAndCheckboxSection: some View {
        HStack {
            // 좌측: 필터 버튼
            Button(action: {
                viewModel.showFilterSheet = true
            }) {
                HStack(spacing: 4) {
                    Image("filterIcon", bundle: .designSystem)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        
                    Text(viewModel.selectedFilter.rawValue)
                        .fontStyle(.body2Medium)
                        .foregroundStyle(ColorSystem.labelNormalNormal)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(ColorSystem.labelNormalDisable)
                .clipShape(RoundedRectangle(cornerRadius: 999))
            }
            
            Spacer()
            
            // 우측: 모집마감 체크박스
            Button(action: {
                viewModel.toggleClosedChallenges()
            }) {
                HStack(spacing: 6) {
                    Image(viewModel.hideClosedChallenges ? "checkIcon" : "noCheckIcon", bundle: .designSystem)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                    
                    Text("모집 마감")
                        .fontStyle(.detail1Medium)
                        .foregroundStyle(ColorSystem.labelNormalBasic)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }
    
    // MARK: - Filter Tags
    private var filterTagsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(viewModel.selectedFilters), id: \.self) { keyword in
                    HStack(spacing: 4) {
                        Text(keyword.title)
                            .fontStyle(.detail1Medium)
                            .foregroundStyle(ColorSystem.primaryStrong)
                        
                        Button {
                            viewModel.removeFilter(keyword)
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(ColorSystem.labelNormalBasic)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(ColorSystem.labelNormalDisable)
                    .cornerRadius(999)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
        }
        .background(ColorSystem.backgroundNormalNormal)
    }
    
    // MARK: - Tab Bar
    private var tabBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(SearchViewModel.SearchTab.allCases, id: \.self) { tab in
                    Button {
                        viewModel.selectedTab = tab
                    } label: {
                        Text(tab.rawValue)
                            .fontStyle(viewModel.selectedTab == tab ? .heading3Bold : .heading3SemiBold)
                            .foregroundStyle(viewModel.selectedTab == tab ? ColorSystem.primaryHeavy : ColorSystem.labelNormalBasic)
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                }
            }
            .padding(.horizontal, 24)
            
            ZStack(alignment: .leading) {
                // 전체 회색 선 (배경)
                Rectangle()
                    .fill(ColorSystem.labelNormalDisable)
                    .frame(height: 2)
                
                // 선택된 탭의 파란색 선
                HStack(spacing: 0) {
                    ForEach(SearchViewModel.SearchTab.allCases, id: \.self) { tab in
                        Rectangle()
                            .fill(viewModel.selectedTab == tab ? ColorSystem.primaryStrong : Color.clear)
                            .frame(height: 2)
                    }
                }
                .padding(.horizontal, 24)
                .animation(.easeInOut(duration: 0.2), value: viewModel.selectedTab)
            }
        }
        .background(ColorSystem.backgroundNormalNormal)
    }
    
    // MARK: - Challenge Results
    private var challengeResultsSection: some View {
        LazyVStack(spacing: 16) {
            ForEach(viewModel.challengeResults) { challenge in
                ChallengeItemView(
                    title: challenge.title,
                    imageUrl: challenge.thumbnailImageUrl ?? "",
                    style: .progressList(
                        progress: "\(Int(challenge.progress))%",
                        author: challenge.author.isEmpty ? "익명" : challenge.author
                    ),
                    isRecruitmentClosed: challenge.isRecruitmentClosed,
                    onTapped: {
                        navigationPath.append(challenge.id)
                    }
                )
            }
        }
    }
    
    // MARK: - Feed Results
    private var feedResultsSection: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 14),
                GridItem(.flexible(), spacing: 14)
            ],
            spacing: 14
        ) {
            ForEach(viewModel.feedResults) { feed in
                FeedThumbnailCard(
                    imageUrl: feed.feedUrl,
                    isMyFeed: feed.isMyFeed,
                    onTap: {
                        navigationPath.append(feed.id)
                    }
                )
            }
        }
    }
}

