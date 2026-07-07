//
//  DiscoverViewModel.swift
//  DiscoverFeature
//
//  Created by Park Seyoung on 8/28/25.
//

import Foundation
import SwiftUI
import ChallengeDomain
import ModelsShared
import UIComponentsShared

// MARK: - KeywordFeedState
struct KeywordFeedState {
    var feeds: [DiscoverFeed] = []
    var currentPage: Int = 0
    var isLoading: Bool = false
    var hasNext: Bool = true
}

// MARK: - DiscoverViewModel
@MainActor
public final class DiscoverViewModel: ObservableObject {
    @Published public var honorsSelectedKeyword: Keyword = .all
    @Published public var feedsSelectedKeyword: Keyword = .all
    @Published var honorsChallenges: [Keyword: HallOfFameData] = [:]
    @Published var keywordFeeds: [Keyword: KeywordFeedState] = [:]
    @Published var alert: AlertState?
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var isInitialLoading: Bool = true

    private let repository: DiscoverRepositoryProtocol

    public init(repository: DiscoverRepositoryProtocol) {
        self.repository = repository
    }

    func clearError() { alert = nil }

    // MARK: - 초기 데이터 병렬 로드
    func loadInitialData(keyword: Keyword, showSkeleton: Bool = false) async {
        if showSkeleton {
            isInitialLoading = true
        }

        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadHonors() }
            group.addTask { await self.loadFeeds(for: keyword, reset: true) }
        }

        if showSkeleton {
            isInitialLoading = false
        }

        // 나머지 카테고리 백그라운드 프리패칭 (스켈레톤 없이)
        prefetchRemainingKeywords(excluding: keyword)
    }

    // MARK: - 명시적 새로고침 (pull-to-refresh)
    func refresh() async {
        keywordFeeds = [:]
        honorsChallenges = [:]

        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadHonors() }
            group.addTask { await self.loadFeeds(for: self.feedsSelectedKeyword, reset: true) }
        }

        prefetchRemainingKeywords(excluding: feedsSelectedKeyword)
    }

    // MARK: - 백그라운드 프리패칭
    private func prefetchRemainingKeywords(excluding loaded: Keyword) {
        let remaining = Keyword.allCases.filter { $0 != loaded }
        Task {
            await withTaskGroup(of: Void.self) { group in
                for keyword in remaining {
                    group.addTask { await self.loadFeeds(for: keyword, reset: false) }
                }
            }
        }
    }

    // MARK: - 명예의 전당 로드
    func loadHonors(showSkeleton: Bool = false) async {
        if showSkeleton {
            isInitialLoading = true
        }
        
        isLoading = true

        do {
            honorsChallenges[honorsSelectedKeyword] = try await repository.fetchHonorsChallenges(by: honorsSelectedKeyword)
        } catch {
            alert = AlertState(title: "오류", message: "명예의 전당 로드 실패: \(error.localizedDescription)")
        }
        
        isLoading = false
        
        if showSkeleton {
            isInitialLoading = false
        }
    }

    // MARK: - 개별 키워드 명예의 전당 로드
    func loadHonors(for keyword: Keyword) async {
        isLoading = true
        do {
            honorsChallenges[keyword] = try await repository.fetchHonorsChallenges(by: keyword)
        } catch {
            alert = AlertState(title: "오류", message: "명예의 전당 로드 실패: \(error.localizedDescription)")
        }
        isLoading = false
    }

    // MARK: - 피드 로드
    func loadFeeds(for keyword: Keyword, reset: Bool = false, showSkeleton: Bool = false) async {
        var state = keywordFeeds[keyword] ?? KeywordFeedState()

        guard !state.isLoading, state.hasNext || reset else { return }

        if reset { state = KeywordFeedState() }
        
        if showSkeleton && reset {
            isInitialLoading = true
        }

        state.isLoading = true
        keywordFeeds[keyword] = state

        do {
            let pageData = try await repository.fetchKeywordFeeds(by: keyword, page: state.currentPage, size: 20)
            
            state.feeds += pageData.content
            state.currentPage += 1
            state.hasNext = pageData.hasNext
            state.isLoading = false
            keywordFeeds[keyword] = state
        } catch {
            state.isLoading = false
            keywordFeeds[keyword] = state
            alert = AlertState(title: "오류", message: "피드 로드 실패: \(error.localizedDescription)")
        }
        
        if showSkeleton && reset {
            isInitialLoading = false
        }
    }
    
    func loadNextFeeds(for keyword: Keyword) async {
        guard let state = keywordFeeds[keyword], state.hasNext, !isLoadingMore else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            var updatedState = state
            let pageData = try await repository.fetchKeywordFeeds(by: keyword, page: updatedState.currentPage, size: 20)
            updatedState.feeds.append(contentsOf: pageData.content)
            updatedState.currentPage += 1
            updatedState.hasNext = pageData.hasNext
            keywordFeeds[keyword] = updatedState
        } catch {
            alert = AlertState(title: "오류", message: "다음 피드 로드 실패: \(error.localizedDescription)")
        }
    }

    // MARK: - 선택 로직 분리
    public func selectHonorsKeyword(_ keyword: Keyword) async {
        honorsSelectedKeyword = keyword
        // 이미 캐시된 데이터가 있으면 재요청 안 함
        guard honorsChallenges[keyword] == nil else { return }
        await loadHonors(for: keyword)
    }

    public func selectFeedsKeyword(_ keyword: Keyword) async {
        feedsSelectedKeyword = keyword
        // 이미 캐시된 데이터가 있으면 재요청 안 함
        if let state = keywordFeeds[keyword], !state.feeds.isEmpty { return }
        await loadFeeds(for: keyword, reset: false)
    }

    // MARK: - 로딩 상태 헬퍼
    /// 현재 선택된 키워드의 피드가 로딩 중이거나 아직 한 번도 로드 안 된 상태
    var isFeedSectionLoading: Bool {
        guard let state = keywordFeeds[feedsSelectedKeyword] else { return true }
        return state.isLoading && state.feeds.isEmpty
    }

    /// 현재 선택된 명예의 전당 키워드가 로딩 중인 상태
    var isHonorsSectionLoading: Bool {
        isLoading && honorsChallenges[honorsSelectedKeyword] == nil
    }
}
