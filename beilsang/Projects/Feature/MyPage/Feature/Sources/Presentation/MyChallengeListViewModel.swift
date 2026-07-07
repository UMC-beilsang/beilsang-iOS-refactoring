//
//  MyChallengeListViewModel.swift
//  MyPageFeature
//
//  Created by Seyoung Park on 11/28/25.
//

import Foundation
import ChallengeDomain
import ModelsShared

@MainActor
public final class MyChallengeListViewModel: ObservableObject {
    @Published public var challenges: [ChallengeItem] = []
    @Published public var isLoading: Bool = true
    @Published public var errorMessage: String?
    @Published public var isInitialLoading: Bool = true
    
    private let queryRepo: ChallengeQueryRepositoryProtocol
    private var currentPage: Int = 0
    private let pageSize: Int = 20
    public var hasNext: Bool = true
    
    public init(queryRepo: ChallengeQueryRepositoryProtocol) {
        self.queryRepo = queryRepo
    }
    
    public func fetchChallenges(
        tabIndex: Int,
        category: Keyword,
        reset: Bool = false,
        showSkeleton: Bool = false
    ) async {
        if reset {
            currentPage = 0
            challenges = []
            hasNext = true
        }
        
        guard hasNext else { return }
        
        if showSkeleton && reset {
            isInitialLoading = true
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let participationStatus: String? = {
                switch tabIndex {
                case 0: return "ONGOING"
                case 1: return "SUCCESS"
                case 2: return "FAIL"
                default: return nil
                }
            }()
            
            let request = MyChallengeListRequest(
                category: category == .all ? nil : category.apiCategory,
                participationStatus: participationStatus,
                page: currentPage,
                size: pageSize
            )
            
            let response = try await queryRepo.fetchMyChallenges(request: request)
            
            let fetchedChallenges = response.content
            
            challenges.append(contentsOf: fetchedChallenges)
            currentPage += 1
            hasNext = response.hasNext
            
            #if DEBUG
            print("🎯 Fetched \(fetchedChallenges.count) challenges for tab: \(tabIndex), category: \(category.rawValue)")
            #endif
        } catch {
            errorMessage = "챌린지 목록을 불러오는 데 실패했습니다."
            #if DEBUG
            print("❌ Error fetching challenges: \(error)")
            #endif
        }
        
        isLoading = false
        
        if showSkeleton && reset {
            isInitialLoading = false
        }
    }
}
