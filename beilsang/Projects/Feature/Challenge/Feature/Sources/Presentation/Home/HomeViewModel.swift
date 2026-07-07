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
    @Published public var activeChallenges: [ChallengeItem] = []
    @Published public var recommendedChallenges: [ChallengeItem] = []
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
        if showSkeleton { isLoading = true }
        
        do {
            async let active = fetchActiveChallengesUseCase.execute()
            async let recommended = fetchRecommendedChallengesUseCase.execute(size: 10)
            let (a, r) = try await (active, recommended)
            activeChallenges = a
            recommendedChallenges = r
        } catch {
            alert = AlertState(
                title: "챌린지를 불러오는 데 실패했습니다.",
                message: "네트워크 연결을 확인해주세요."
            )
        }
        
        if showSkeleton { isLoading = false }
    }
}
