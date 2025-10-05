//
//  ChallengeListViewModel.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 10/2/25.
//

import Foundation
import ChallengeDomain
import ModelsShared

@MainActor
final class ChallengeListViewModel: ObservableObject {
    @Published var items: [ChallengeItemViewModel] = []
    
    private let repository: ChallengeRepositoryProtocol
    
    init(repository: ChallengeRepositoryProtocol) {
        self.repository = repository
    }
    
    func fetchChallenges(for category: Keyword) async {
        do {
            let challenges: [Challenge]
            
            switch category {
            case .all:
                challenges = try await repository.fetchActiveChallenges()
            default:
                challenges = try await repository.fetchRecommendedChallenges()
            }
            
            self.items = challenges.map { ChallengeItemViewModel(challenge: $0) }
        } catch {
            print("❌ Error: \(error)")
        }
    }
}
