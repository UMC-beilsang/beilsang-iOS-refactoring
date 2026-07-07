//
//  SearchViewModel.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 11/30/25.
//

import Foundation
import ChallengeDomain
import ModelsShared

@MainActor
public final class SearchViewModel: ObservableObject {
    @Published public var searchText: String = ""
    @Published public var recentSearches: [String] = []
    @Published public var challengeResults: [ChallengeItem] = []
    @Published public var feedResults: [SearchFeedItem] = []
    @Published public var selectedTab: SearchTab = .challenge
    @Published public var isLoading: Bool = false
    @Published public var hasSearched: Bool = false
    @Published public var showEmptyState: Bool = false
    
    public var currentTabIsEmpty: Bool {
        switch selectedTab {
        case .challenge:
            return challengeResults.isEmpty
        case .feed:
            return feedResults.isEmpty
        }
    }
    @Published public var selectedFilters: Set<Keyword> = []
    @Published public var recommendedChallenges: [ChallengeItem] = []
    
    @Published public var selectedFilter: ChallengeFilter = .recent
    @Published public var showFilterSheet: Bool = false
    @Published public var hideClosedChallenges: Bool = false
    
    private var allChallengeResults: [ChallengeItem] = []
    
    private let queryRepo: ChallengeQueryRepositoryProtocol
    private let feedRepo: FeedRepositoryProtocol
    private let fetchRecommendedChallengesUseCase: FetchRecommendedChallengesUseCaseProtocol
    private let recentSearchesKey = "recentSearches"
    
    public enum SearchTab: String, CaseIterable {
        case challenge = "챌린지"
        case feed = "피드"
    }
    
    public init(
        queryRepo: ChallengeQueryRepositoryProtocol,
        feedRepo: FeedRepositoryProtocol,
        fetchRecommendedChallengesUseCase: FetchRecommendedChallengesUseCaseProtocol
    ) {
        self.queryRepo = queryRepo
        self.feedRepo = feedRepo
        self.fetchRecommendedChallengesUseCase = fetchRecommendedChallengesUseCase
        loadRecentSearches()
    }
    
    // MARK: - Recent Searches
    private func loadRecentSearches() {
        if let data = UserDefaults.standard.array(forKey: recentSearchesKey) as? [String] {
            recentSearches = data
        }
    }
    
    private func saveRecentSearches() {
        UserDefaults.standard.set(recentSearches, forKey: recentSearchesKey)
    }
    
    public func addRecentSearch(_ search: String) {
        let trimmed = search.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        // 중복 제거
        recentSearches.removeAll { $0 == trimmed }
        // 맨 앞에 추가
        recentSearches.insert(trimmed, at: 0)
        // 최대 10개만 유지
        if recentSearches.count > 10 {
            recentSearches = Array(recentSearches.prefix(10))
        }
        saveRecentSearches()
    }
    
    public func removeRecentSearch(_ search: String) {
        recentSearches.removeAll { $0 == search }
        saveRecentSearches()
    }
    
    public func clearAllRecentSearches() {
        recentSearches = []
        saveRecentSearches()
    }
    
    // MARK: - Search
    public func performSearch(query: String) async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        // 상태 업데이트를 한 번에 처리
        await MainActor.run {
            searchText = trimmed
            hasSearched = true
            isLoading = true
            showEmptyState = false
        }
        
        addRecentSearch(trimmed)

        async let searchTask = Task {
            await performActualSearch(query: trimmed)
        }

        await searchTask.value

        await MainActor.run {
            isLoading = false
        }
    }
    
    private func performActualSearch(query: String) async {
        do {
            var challenges: [ChallengeItem] = []
            
            if hideClosedChallenges {
                let closedRequest = SearchClosedChallengeRequest(keyword: query, page: 0, size: 20)
                let closedResponse = try await queryRepo.searchClosedChallenges(request: closedRequest)
                challenges = closedResponse.content
            } else {
                let sortType = selectedFilter == .recent ? "DEADLINE_SOON" : "NEWEST"
                let challengeRequest = SearchOpenChallengeRequest(
                    keyword: query,
                    sortType: sortType,
                    page: 0,
                    size: 20
                )
                let challengeResponse = try await queryRepo.searchOpenChallenges(request: challengeRequest)
                challenges = challengeResponse.content
            }
            
            let feedPageData = try await feedRepo.searchFeeds(
                keyword: query,
                sortType: "NEWEST",
                category: nil,
                page: 0,
                size: 10
            )
            
            await MainActor.run {
                allChallengeResults = challenges
                feedResults = feedPageData.content
                applyAllFilters()
                showEmptyState = challengeResults.isEmpty && feedResults.isEmpty
            }
            
            #if DEBUG
            print("🔍 Search results - Challenges: \(challenges.count), Feeds: \(feedPageData.content.count)")
            #endif
        } catch {
            #if DEBUG
            print("❌ Search error: \(error)")
            #endif
            await MainActor.run {
                allChallengeResults = []
                challengeResults = []
                feedResults = []
                showEmptyState = true
            }
        }
    }
    
    // MARK: - Sort & Filter
    public func applyFilter(_ filter: ChallengeFilter) {
        selectedFilter = filter
        showFilterSheet = false
        if hasSearched, !searchText.isEmpty {
            Task { await performSearch(query: searchText) }
        } else {
            applyAllFilters()
        }
    }
    
    public func toggleClosedChallenges() {
        hideClosedChallenges.toggle()
        if hasSearched, !searchText.isEmpty {
            Task { await performSearch(query: searchText) }
        } else {
            applyAllFilters()
        }
    }
    
    private func applyAllFilters() {
        challengeResults = allChallengeResults
    }
    
    // MARK: - Filters
    public func addFilter(_ keyword: Keyword) {
        guard keyword != .all else { return }
        selectedFilters.insert(keyword)
    }
    
    public func removeFilter(_ keyword: Keyword) {
        selectedFilters.remove(keyword)
    }
    
    public func clearAllFilters() {
        selectedFilters.removeAll()
    }
    
    // MARK: - Recommended Challenges
    public func loadRecommendedChallenges() async {
        do {
            recommendedChallenges = try await fetchRecommendedChallengesUseCase.execute(size: 10)
        } catch {
            #if DEBUG
            print("❌ Error loading recommended challenges: \(error)")
            #endif
            recommendedChallenges = []
        }
    }
}

