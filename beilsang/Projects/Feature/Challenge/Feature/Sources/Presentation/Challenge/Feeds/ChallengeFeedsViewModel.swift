//
//  ChallengeFeedsViewModel.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/16/25.
//

import ChallengeDomain
import ModelsShared
import SwiftUI
import UtilityShared

@MainActor
public final class ChallengeFeedsViewModel: ObservableObject {
    @Published var thumbnails: [ChallengeFeedThumbnail] = []
    @Published var isLoading = false
    @Published var hasNext = true
    @Published var showFeedDetail = false
    @Published var selectedFeedId: Int?
    
    private let challengeId: Int
    let repository: ChallengeRepositoryProtocol
    private var currentPage = 0
    
    public init(challengeId: Int, repository: ChallengeRepositoryProtocol) {
        self.challengeId = challengeId
        self.repository = repository
    }
    
    func loadFeeds(showSkeleton: Bool = false) async {
        guard !isLoading else { return }
        
        if showSkeleton {
            isLoading = true
        }
        
        let shouldDelay = showSkeleton && MockConfig.useMockData
        let delayTask: Task<Void, Never>? = shouldDelay ? Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        } : nil
        
        do {
            let response = try await repository.fetchChallengeFeedThumbnails(
                challengeId: challengeId,
                page: currentPage
            )
            
            if let delay = delayTask {
                await delay.value
            }
            
            if currentPage == 0 {
                thumbnails = response.feeds
            } else {
                thumbnails.append(contentsOf: response.feeds)
            }
            
            hasNext = response.hasNext
            currentPage += 1
            
        } catch {
            if let delay = delayTask {
                await delay.value
            }
            print("피드 로딩 실패: \(error)")
        }
        
        if showSkeleton {
            isLoading = false
        }
    }
    
    func loadMoreFeeds() async {
        guard hasNext && !isLoading else { return }
        await loadFeeds()
    }
    
    func showFeedDetail(feedId: Int) {
        selectedFeedId = feedId
        showFeedDetail = true
    }
    
    func dismissFeedDetail() {
        showFeedDetail = false
        selectedFeedId = nil
    }
}
