//
//  HomeViewModel.swift
//  ChallengeFeature
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

@MainActor
public final class HomeViewModel: ObservableObject {
    // MARK: - Published
    @Published public var activeChallenges: [Challenge] = [] 
    @Published public var recommendedChallenges: [Challenge] = []
    @Published public var isLoading: Bool = true // 초기 로딩 상태
    @Published public var alert: AlertState?
    
    // MARK: - Private
    private var cancellables = Set<AnyCancellable>()
    private let fetchActiveChallengesUseCase: FetchActiveChallengesUseCaseProtocol
    private let fetchRecommendedChallengesUseCase: FetchRecommendedChallengesUseCaseProtocol
    
    // MARK: - Init
    public init(
        fetchActiveChallengesUseCase: FetchActiveChallengesUseCaseProtocol,
        fetchRecommendedChallengesUseCase: FetchRecommendedChallengesUseCaseProtocol
    ) {
        self.fetchActiveChallengesUseCase = fetchActiveChallengesUseCase
        self.fetchRecommendedChallengesUseCase = fetchRecommendedChallengesUseCase
    }
    
    // MARK: - Public Methods
    public func clearError() {
        alert = nil
    }
    
    public func loadChallenges(showSkeleton: Bool = false) async {
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
                let active = try await fetchActiveChallengesUseCase.execute()
                let recommended = try await fetchRecommendedChallengesUseCase.execute()
                return (active, recommended)
            } catch {
                throw error
            }
        }
        
        do {
            let (active, recommended) = try await fetchTask.value
            if let delay = delayTask {
                await delay.value // 목업일 때만 최소 0.5초 대기
            }
            
            activeChallenges = active
            recommendedChallenges = recommended
        } catch {
            if let delay = delayTask {
                await delay.value // 에러 발생 시에도 목업일 때만 최소 0.5초 대기
            }
            alert = AlertState(
                title: "챌린지를 불러오는 데 실패했습니다.",
                message: "네트워크 연결을 확인해주세요."
            )
        }
        
        if showSkeleton {
            isLoading = false
        }
    }
}
