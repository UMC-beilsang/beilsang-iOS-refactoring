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
    private var currentPage = 0
    
    public init(challengeId: Int) {
        self.challengeId = challengeId
    }
    
    func loadFeeds(showSkeleton: Bool = false) async {
        guard !isLoading else { return }
        // TODO: 백엔드 API 추가되면 구현
        thumbnails = []
        hasNext = false
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
