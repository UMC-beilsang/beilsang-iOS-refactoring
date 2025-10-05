//
//  ChallengeContainer.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/1/25.
//

import ChallengeDomain

@MainActor
public final class ChallengeContainer {
    public let homeViewModel: HomeViewModel
    public let router: ChallengeRouter
    
    public init() {
        // 데이터 레이어 (Repository)
        let repository = MockChallengeRepository()
        
        // ViewModel 생성
        self.homeViewModel = HomeViewModel(repository: repository)
        
        // Router 생성
        self.router = ChallengeRouter()
    }
}
