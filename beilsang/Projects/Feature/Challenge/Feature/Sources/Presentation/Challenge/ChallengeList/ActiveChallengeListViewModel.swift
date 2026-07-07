//
//  ActiveChallengeListViewModel.swift
//  ChallengeFeature
//

import Foundation
import ChallengeDomain
import ModelsShared

@MainActor
public final class ActiveChallengeListViewModel: ObservableObject {
    @Published public var items: [ChallengeItemViewModel] = []
    @Published public var isLoading: Bool = true
    @Published public var selectedFilter: ChallengeFilter = .recent
    @Published public var showFilterSheet: Bool = false

    private let fetchActiveChallengesUseCase: FetchActiveChallengesUseCaseProtocol

    public init(fetchActiveChallengesUseCase: FetchActiveChallengesUseCaseProtocol) {
        self.fetchActiveChallengesUseCase = fetchActiveChallengesUseCase
    }

    public func load() async {
        isLoading = true
        do {
            let challenges = try await fetchActiveChallengesUseCase.execute()
            let viewModels = challenges.map { ChallengeItemViewModel(challengeItem: $0, isClosed: false) }
            items = applyFilter(viewModels)
        } catch {
            items = []
            print("❌ 참여 중인 챌린지 로드 실패: \(error)")
        }
        isLoading = false
    }

    public func applyFilter(_ filter: ChallengeFilter) async {
        selectedFilter = filter
        showFilterSheet = false
        await load()
    }

    private func applyFilter(_ viewModels: [ChallengeItemViewModel]) -> [ChallengeItemViewModel] {
        switch selectedFilter {
        case .recent:
            return viewModels.sorted { $0.startDate > $1.startDate }
        case .latest:
            return viewModels.sorted { $0.createdAt > $1.createdAt }
        }
    }
}
