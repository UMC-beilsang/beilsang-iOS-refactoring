//
//  ChallengeListViewModel.swift
//  ChallengeFeature
//  Created by Seyoung Park on 9/3/25.
//

import Foundation
import ChallengeDomain
import ModelsShared
import UtilityShared

@MainActor
public final class ChallengeListViewModel: ObservableObject {
    @Published public var items: [ChallengeItemViewModel] = []
    @Published public var isLoading: Bool = true // 초기 로딩 상태
    
    private let fetchChallengeListUseCase: FetchChallengeListUseCaseProtocol
    
    public init(fetchChallengeListUseCase: FetchChallengeListUseCaseProtocol) {
        self.fetchChallengeListUseCase = fetchChallengeListUseCase
    }
    
    public func fetchChallenges(for category: Keyword, showSkeleton: Bool = false) async {
        if showSkeleton {
            isLoading = true
        }
        
        // 목업 데이터일 때만 최소 0.5초 스켈레톤 UI 표시를 위한 지연
        let shouldDelay = showSkeleton && MockConfig.useMockData
        let delayTask: Task<Void, Never>? = shouldDelay ? Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5초
        } : nil
        
        async let fetchTask = Task {
            do {
                // 카테고리별 챌린지 조회 - 전체 챌린지 조회 (신청 마감 포함)
                let request = ChallengeListRequest(
                    page: 0,
                    size: 20,
                    category: category == .all ? nil : category.apiCategory,
                    challengeStatus: nil, // 전체 챌린지 (신청 마감 포함)
                    isFinished: nil, // 종료 여부 상관없이
                    isJoined: nil
                )
                
                let challenges = try await fetchChallengeListUseCase.execute(request: request)
                
                #if DEBUG
                print("🎯 Fetched \(challenges.count) challenges for category: \(category.rawValue)")
                #endif
                
                return challenges.map { ChallengeItemViewModel(challenge: $0) }
            } catch {
                print("❌ Error fetching challenges: \(error)")
                return []
            }
        }
        
        do {
            let items = try await fetchTask.value
            if let delay = delayTask {
                await delay.value // 목업일 때만 최소 0.5초 대기
            }
            
            self.items = items
        } catch {
            if let delay = delayTask {
                await delay.value // 에러 발생 시에도 목업일 때만 최소 0.5초 대기
            }
            self.items = []
        }
        
        if showSkeleton {
            isLoading = false
        }
    }
}
