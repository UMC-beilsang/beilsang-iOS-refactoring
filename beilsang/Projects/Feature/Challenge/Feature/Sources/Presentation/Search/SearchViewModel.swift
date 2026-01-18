//
//  SearchViewModel.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 11/30/25.
//

import Foundation
import ChallengeDomain
import ModelsShared
import UtilityShared

@MainActor
public final class SearchViewModel: ObservableObject {
    @Published public var searchText: String = ""
    @Published public var recentSearches: [String] = []
    @Published public var challengeResults: [Challenge] = []
    @Published public var feedResults: [ChallengeFeedDetail] = []
    @Published public var selectedTab: SearchTab = .challenge
    @Published public var isLoading: Bool = false
    @Published public var hasSearched: Bool = false
    @Published public var showEmptyState: Bool = false
    @Published public var selectedFilters: Set<Keyword> = []
    @Published public var recommendedChallenges: [Challenge] = []
    
    private let repository: ChallengeRepositoryProtocol
    private let fetchRecommendedChallengesUseCase: FetchRecommendedChallengesUseCaseProtocol
    private let recentSearchesKey = "recentSearches"
    
    public enum SearchTab: String, CaseIterable {
        case challenge = "챌린지"
        case feed = "피드"
    }
    
    public init(
        repository: ChallengeRepositoryProtocol,
        fetchRecommendedChallengesUseCase: FetchRecommendedChallengesUseCaseProtocol
    ) {
        self.repository = repository
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
        
        // 목업 데이터일 때만 최소 0.5초 스켈레톤 UI 표시를 위한 지연
        let shouldDelay = MockConfig.useMockData
        let delayTask: Task<Void, Never>? = shouldDelay ? Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5초
        } : nil
        
        async let searchTask = Task {
            await performActualSearch(query: trimmed)
        }
        
        await searchTask.value
        
        if let delay = delayTask {
            await delay.value // 목업일 때만 최소 0.5초 대기
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    private func performActualSearch(query: String) async {
        do {
            // 챌린지 검색
            let challengeRequest = ChallengeListRequest(
                page: 0,
                size: 20,
                keyword: query
            )
            let challenges = try await repository.fetchChallengeList(request: challengeRequest)
            
            // 피드 검색 (일단 빈 결과, 나중에 피드 검색 API 추가 필요)
            let feedListResponse = try await repository.fetchFeedList(category: nil, page: 0, size: 20)
            let feeds = feedListResponse.content.map { feedItem in
                ChallengeFeedDetail(
                    id: feedItem.feedId,
                    feedUrl: feedItem.feedUrl,
                    day: feedItem.day,
                    userName: "비밀상님",
                    userProfileImageUrl: nil,
                    description: "",
                    likeCount: 0,
                    isLiked: false,
                    challengeTags: [],
                    createdAt: Date(),
                    isMyFeed: false
                )
            }
            
            await MainActor.run {
                challengeResults = challenges
                feedResults = feeds
                showEmptyState = challenges.isEmpty && feeds.isEmpty
            }
            
            #if DEBUG
            print("🔍 Search results - Challenges: \(challenges.count), Feeds: \(feeds.count)")
            #endif
        } catch {
            #if DEBUG
            print("❌ Search error: \(error)")
            #endif
            await MainActor.run {
                challengeResults = []
                feedResults = []
                showEmptyState = true
            }
        }
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
            recommendedChallenges = try await fetchRecommendedChallengesUseCase.execute()
        } catch {
            #if DEBUG
            print("❌ Error loading recommended challenges: \(error)")
            #endif
            recommendedChallenges = []
        }
    }
}

