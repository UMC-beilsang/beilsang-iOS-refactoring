//
//  ChallengeFeedsViewModel.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/16/25.
//

import ChallengeDomain
import ModelsShared
import SwiftUI

@MainActor
class ChallengeFeedsViewModel: ObservableObject {
    @Published var thumbnails: [ChallengeFeedThumbnail] = []
    @Published var isLoading = false
    @Published var hasNext = true
    @Published var showFeedDetail = false
    @Published var selectedFeedId: Int?
    
    private let challengeId: Int
    let repository: ChallengeRepositoryProtocol
    private var currentPage = 0
    
    init(challengeId: Int, repository: ChallengeRepositoryProtocol) {
        self.challengeId = challengeId
        self.repository = repository
    }
    
    func loadFeeds() async {
        guard !isLoading else { return }
        
        isLoading = true
        do {
            let response = try await repository.fetchChallengeFeedThumbnails(
                challengeId: challengeId,
                page: currentPage
            )
            
            if currentPage == 0 {
                thumbnails = response.feeds
            } else {
                thumbnails.append(contentsOf: response.feeds)
            }
            
            hasNext = response.hasNext
            currentPage += 1
            
        } catch {
            print("피드 로딩 실패: \(error)")
        }
        isLoading = false
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
