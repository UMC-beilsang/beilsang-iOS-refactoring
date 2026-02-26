//
//  ChallengeContainer.swift
//  ChallengeFeature
//

import Foundation
import Alamofire
import ChallengeDomain
import StorageCore
import NetworkCore

@MainActor
public final class ChallengeContainer {
    // MARK: - Properties
    public let homeViewModel: HomeViewModel
    public let challengeAddViewModel: ChallengeAddViewModel
    
    private let challengeRepository: ChallengeRepositoryProtocol
    private let baseURL: String
    private let tokenStorage: KeychainTokenStorageProtocol

    // MARK: - Designated Init
    public init(baseURL: String, tokenStorage: KeychainTokenStorageProtocol = KeychainTokenStorage()) {
        self.baseURL = baseURL
        self.tokenStorage = tokenStorage
        
        // AuthInterceptor로 토큰 자동 추가
        let interceptor = AuthInterceptor(tokenStorage: tokenStorage, baseURL: baseURL)
        let session = Session(interceptor: interceptor)
        let apiClient = APIClient(baseURL: baseURL, session: session)
        let repository = ChallengeRepository(apiClient: apiClient)
        
        self.challengeRepository = repository
        
        // UseCases
        let fetchActiveChallengesUseCase = FetchActiveChallengesUseCase(repository: repository)
        let fetchRecommendedChallengesUseCase = FetchRecommendedChallengesUseCase(repository: repository)
        let createChallengeUseCase = CreateChallengeUseCase(repository: repository)
        
        // Root ViewModels
        self.homeViewModel = HomeViewModel(
            fetchActiveChallengesUseCase: fetchActiveChallengesUseCase,
            fetchRecommendedChallengesUseCase: fetchRecommendedChallengesUseCase
        )
        self.challengeAddViewModel = ChallengeAddViewModel(
            createChallengeUseCase: createChallengeUseCase
        )
    }
    
    // MARK: - Convenience Init
    public convenience init() {
        let baseURL = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String ?? ""
        self.init(baseURL: baseURL)
    }

    // MARK: - Factory Methods
    public func makeChallengeListViewModel() -> ChallengeListViewModel {
        let useCase = FetchChallengeListUseCase(repository: challengeRepository)
        return ChallengeListViewModel(fetchChallengeListUseCase: useCase)
    }

    public func makeChallengeDetailViewModel(challengeId: Int) -> ChallengeDetailViewModel {
        let fetchDetailUseCase = FetchChallengeDetailUseCase(repository: challengeRepository)
        let checkEnrollmentUseCase = CheckChallengeEnrollmentUseCase(repository: challengeRepository)
        let fetchRecommendedUseCase = FetchRecommendedChallengesUseCase(repository: challengeRepository)
        let fetchFeedThumbnailsUseCase = FetchChallengeFeedThumbnailsUseCase(repository: challengeRepository)
        let joinChallengeUseCase = JoinChallengeUseCase(repository: challengeRepository)
        
        return ChallengeDetailViewModel(
            challengeId: challengeId,
            repository: challengeRepository,
            fetchDetailUseCase: fetchDetailUseCase,
            checkEnrollmentUseCase: checkEnrollmentUseCase,
            fetchRecommendedChallengesUseCase: fetchRecommendedUseCase,
            fetchFeedThumbnailsUseCase: fetchFeedThumbnailsUseCase,
            joinChallengeUseCase: joinChallengeUseCase
        )
    }
    
    public func makeChallengeFeedDetailViewModel(feedId: Int) -> ChallengeFeedDetailViewModel {
        ChallengeFeedDetailViewModel(
            feedId: feedId,
            repository: challengeRepository
        )
    }
    
    public func makeChallengeCertViewModel(challengeId: Int) -> ChallengeCertViewModel {
        ChallengeCertViewModel(challengeId: challengeId, repository: challengeRepository)
    }
    
    public func makeSearchViewModel() -> SearchViewModel {
        let fetchRecommendedChallengesUseCase = FetchRecommendedChallengesUseCase(repository: challengeRepository)
        return SearchViewModel(
            repository: challengeRepository,
            fetchRecommendedChallengesUseCase: fetchRecommendedChallengesUseCase
        )
    }
}
