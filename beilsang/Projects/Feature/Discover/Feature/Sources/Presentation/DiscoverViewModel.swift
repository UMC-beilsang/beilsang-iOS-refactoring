//
//  DiscoverViewModel.swift
//  DiscoverFeature
//
//  Created by Park Seyoung on 8/28/25.
//

import Foundation
import Combine
import SwiftUI
import ChallengeDomain
import ModelsShared
import UIComponentsShared
import UtilityShared

// MARK: - KeywordFeedState
struct KeywordFeedState {
    var feeds: [ChallengeFeedDetail] = []
    var currentPage: Int = 1
    var isLoading: Bool = false
    var hasNext: Bool = true
}

// MARK: - DiscoverViewModel
@MainActor
public final class DiscoverViewModel: ObservableObject {
    @Published public var honorsSelectedKeyword: Keyword = .all
    @Published public var feedsSelectedKeyword: Keyword = .all
    @Published var honorsChallenges: [Keyword: [Challenge]] = [:]
    @Published var keywordFeeds: [Keyword: KeywordFeedState] = [:]
    @Published var alert: AlertState?
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var currentPage: [Keyword: Int] = [:]
    @Published var isInitialLoading: Bool = true

    private let repository: ChallengeRepositoryProtocol

    public init(repository: ChallengeRepositoryProtocol) {
        self.repository = repository
    }

    func clearError() { alert = nil }

    // MARK: - 명예의 전당 로드
    func loadHonors(showSkeleton: Bool = false) async {
        if showSkeleton {
            isInitialLoading = true
        }
        
        isLoading = true
        
        let shouldDelay = showSkeleton && MockConfig.useMockData
        let delayTask: Task<Void, Never>? = shouldDelay ? Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        } : nil

        do {
            var honors: [Keyword: [Challenge]] = [:]
            for keyword in Keyword.allCases {
                honors[keyword] = try await repository.fetchHonorsChallenges(by: keyword)
            }
            
            if let delay = delayTask {
                await delay.value
            }
            
            honorsChallenges = honors
        } catch {
            if let delay = delayTask {
                await delay.value
            }
            alert = AlertState(title: "오류", message: "명예의 전당 로드 실패: \(error.localizedDescription)")
        }
        
        isLoading = false
        
        if showSkeleton {
            isInitialLoading = false
        }
    }

    // MARK: - 개별 키워드 명예의 전당 로드
    func loadHonors(for keyword: Keyword) async {
        do {
            let challenges = try await repository.fetchHonorsChallenges(by: keyword)
            honorsChallenges[keyword] = challenges
        } catch {
            alert = AlertState(title: "오류", message: "명예의 전당 로드 실패: \(error.localizedDescription)")
        }
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
        
        let shouldDelay = showSkeleton && reset && MockConfig.useMockData
        let delayTask: Task<Void, Never>? = shouldDelay ? Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        } : nil

        do {
            let newFeeds = try await repository.fetchKeywordFeeds(by: keyword, page: state.currentPage)
            
            if let delay = delayTask {
                await delay.value
            }
            
            state.feeds += newFeeds
            state.currentPage += 1
            state.hasNext = newFeeds.count >= 1
            state.isLoading = false
            keywordFeeds[keyword] = state
        } catch {
            if let delay = delayTask {
                await delay.value
            }
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
                let newFeeds = try await repository.fetchKeywordFeeds(by: keyword, page: updatedState.currentPage)
                updatedState.feeds.append(contentsOf: newFeeds)
                updatedState.currentPage += 1
                updatedState.hasNext = !newFeeds.isEmpty
                keywordFeeds[keyword] = updatedState
            } catch {
                alert = AlertState(title: "오류", message: "다음 피드 로드 실패: \(error.localizedDescription)")
            }
        }

    // MARK: - 선택 로직 분리
    public func selectHonorsKeyword(_ keyword: Keyword) async {
        honorsSelectedKeyword = keyword
        await loadHonors(for: keyword)
    }

    public func selectFeedsKeyword(_ keyword: Keyword) async {
        feedsSelectedKeyword = keyword
        await loadFeeds(for: keyword, reset: true)
    }
}
