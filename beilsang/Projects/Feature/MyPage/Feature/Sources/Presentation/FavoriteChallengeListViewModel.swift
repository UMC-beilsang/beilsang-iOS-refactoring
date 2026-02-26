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
    @Published public var challenges: [Challenge] = []
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    
    private let repository: ChallengeRepositoryProtocol
    private var currentPage: Int = 0
    private let pageSize: Int = 20
    public var hasNext: Bool = true
    
    public init(repository: ChallengeRepositoryProtocol) {
        self.repository = repository
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
            // 찜한 챌린지는 모든 상태의 챌린지를 조회
            let request = ChallengeListRequest(
                page: currentPage,
                size: pageSize,
                category: category == .all ? nil : category.apiCategory,
                challengeStatus: nil, // 모든 상태의 챌린지
                isFinished: nil, // 종료 여부 상관없이
                isJoined: nil
            )
            
            // 먼저 모든 챌린지를 가져와서 찜한 챌린지만 필터링
            // 카테고리 필터 없이 전체 챌린지 조회
            let allChallengesRequest = ChallengeListRequest(
                page: currentPage,
                size: pageSize * 3, // 더 많이 가져와서 필터링 후 충분한 수 확보
                category: nil, // 카테고리 필터 제거
                challengeStatus: nil,
                isFinished: nil,
                isJoined: nil
            )
            
            var fetchedChallenges = try await repository.fetchChallengeList(request: allChallengesRequest)
            
            // 찜한 챌린지만 필터링 (isLiked == true)
            fetchedChallenges = fetchedChallenges.filter { $0.isLiked }
            
            // 카테고리 필터링 적용
            if category != .all {
                fetchedChallenges = fetchedChallenges.filter { $0.category == category.rawValue }
            }
            
            challenges.append(contentsOf: fetchedChallenges)
            currentPage += 1
            
            hasNext = fetchedChallenges.count >= pageSize
            
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

