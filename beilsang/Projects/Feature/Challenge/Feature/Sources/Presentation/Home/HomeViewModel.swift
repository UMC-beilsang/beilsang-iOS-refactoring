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

@MainActor
public final class HomeViewModel: ObservableObject {
    // MARK: - Published
    @Published var activeChallenges: [Challenge] = []
    @Published var recommendedChallenges: [Challenge] = []
    @Published var isLoading: Bool = false
    @Published var alert: AlertState?
    
    // MARK: - Init, Usecase
    private var cancellables = Set<AnyCancellable>()
    private let repository: ChallengeRepositoryProtocol
    
    func clearError() { alert = nil }
    
    init(repository: ChallengeRepositoryProtocol = MockChallengeRepository()) {
        self.repository = repository
    }
    
    // MARK: - Mock Data (UI 테스트용)
    func loadChallenges() async {
            isLoading = true
            do {
                activeChallenges = try await repository.fetchActiveChallenges()
                recommendedChallenges = try await repository.fetchRecommendedChallenges()
            } catch {
                alert = AlertState(title: "챌린지를 불러오는 데 실패했습니다.", message: "왜요?")
            }
            isLoading = false
        }
}
