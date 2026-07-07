//
//  FavoriteChallengeListViewModel.swift
//  MyPageFeature
//
//  Created by Seyoung Park on 11/30/25.
//

import Foundation
import ChallengeDomain
import ModelsShared

@MainActor
public final class FavoriteChallengeListViewModel: ObservableObject {
    @Published public var challenges: [ChallengeItem] = []
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    
    private let queryRepo: ChallengeQueryRepositoryProtocol
    private var currentPage: Int = 0
    private let pageSize: Int = 20
    public var hasNext: Bool = true
    
    public init(queryRepo: ChallengeQueryRepositoryProtocol) {
        self.queryRepo = queryRepo
    }
    
    public func fetchFavoriteChallenges(category: Keyword, reset: Bool = false) async {
        if reset {
            challenges = []
            currentPage = 0
            hasNext = true
        }
        
        guard hasNext && !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let request = LikedChallengeListRequest(
                category: category == .all ? nil : category.apiCategory,
                sortType: "DEADLINE_SOON",
                page: currentPage,
                size: pageSize
            )
            
            let response = try await queryRepo.fetchLikedChallenges(request: request)
            
            let fetchedChallenges = response.content
            
            challenges.append(contentsOf: fetchedChallenges)
            currentPage += 1
            hasNext = response.hasNext
            
            #if DEBUG
            print("❤️ Fetched \(fetchedChallenges.count) favorite challenges for category: \(category.rawValue)")
            #endif
        } catch {
            errorMessage = "찜한 챌린지 목록을 불러오는 데 실패했습니다."
            #if DEBUG
            print("❌ Error fetching favorite challenges: \(error)")
            #endif
        }
        
        isLoading = false
    }
}

