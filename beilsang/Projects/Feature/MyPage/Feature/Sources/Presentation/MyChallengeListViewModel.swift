//
//  MyChallengeListViewModel.swift
//  MyPageFeature
//
//  Created by Seyoung Park on 11/28/25.
//

import Foundation
import ChallengeDomain
import ModelsShared
import UtilityShared

@MainActor
public final class MyChallengeListViewModel: ObservableObject {
    @Published public var challenges: [Challenge] = []
    @Published public var isLoading: Bool = true
    @Published public var errorMessage: String?
    @Published public var isInitialLoading: Bool = true
    
    private let repository: ChallengeRepositoryProtocol
    private var currentPage: Int = 0
    private let pageSize: Int = 20
    public var hasNext: Bool = true
    
    public init(repository: ChallengeRepositoryProtocol) {
        self.repository = repository
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
        
        let shouldDelay = showSkeleton && reset && MockConfig.useMockData
        let delayTask: Task<Void, Never>? = shouldDelay ? Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        } : nil
        
        do {
            // 탭에 따른 challengeMemberStatus 설정
            let memberStatus: ChallengeMemberStatus? = {
                switch tabIndex {
                case 0: // 참여
                    return nil // 참여 중인 것은 isJoined로 필터링
                case 1: // 달성
                    return .success
                case 2: // 실패
                    return .fail
                default:
                    return nil
                }
            }()
            
            let request = ChallengeListRequest(
                page: currentPage,
                size: pageSize,
                category: category == .all ? nil : category.apiCategory,
                challengeMemberStatus: memberStatus,
                isJoined: tabIndex == 0 ? true : nil // 참여 탭일 때만 true
            )
            
            let fetchedChallenges = try await repository.fetchChallengeList(request: request)
            
            if let delay = delayTask {
                await delay.value
            }
            
            challenges.append(contentsOf: fetchedChallenges)
            currentPage += 1
            
            // TODO: 실제 API 응답에서 hasNext 확인 필요
            // 현재는 가져온 데이터가 pageSize보다 작으면 더 이상 없다고 가정
            hasNext = fetchedChallenges.count >= pageSize
            
            #if DEBUG
            print("🎯 Fetched \(fetchedChallenges.count) challenges for tab: \(tabIndex), category: \(category.rawValue)")
            #endif
        } catch {
            if let delay = delayTask {
                await delay.value
            }
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



