//
//  ChallengeContainer.swift
//  ChallengeFeature
//

import Foundation
import Alamofire
import ChallengeDomain
import UserDomain
import StorageCore
import NetworkCore
import ModelsShared

@MainActor
public final class ChallengeContainer {
    public let homeViewModel: HomeViewModel
    
    private let apiClient: APIClientProtocol
    private let queryRepo: ChallengeQueryRepositoryProtocol
    private let commandRepo: ChallengeCommandRepositoryProtocol
    private let feedRepo: FeedRepositoryProtocol

    public init(baseURL: String, tokenStorage: KeychainTokenStorageProtocol = KeychainTokenStorage()) {
        let interceptor = AuthInterceptor(tokenStorage: tokenStorage, baseURL: baseURL)
        let session = Session(interceptor: interceptor)
        let apiClient = APIClient(baseURL: baseURL, session: session)
        self.apiClient = apiClient
        
        let queryRepo = ChallengeQueryRepository(apiClient: apiClient)
        let commandRepo = ChallengeCommandRepository(apiClient: apiClient)
        let feedRepo = FeedRepository(apiClient: apiClient)
        
        self.queryRepo = queryRepo
        self.commandRepo = commandRepo
        self.feedRepo = feedRepo
        
        let fetchActiveChallengesUseCase = FetchActiveChallengesUseCase(repository: queryRepo)
        let fetchRecommendedChallengesUseCase = FetchRecommendedChallengesUseCase(repository: queryRepo)

        self.homeViewModel = HomeViewModel(
            fetchActiveChallengesUseCase: fetchActiveChallengesUseCase,
            fetchRecommendedChallengesUseCase: fetchRecommendedChallengesUseCase
        )
    }
    
    public convenience init() {
        let baseURL = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String ?? ""
        self.init(baseURL: baseURL)
    }

    public func makeChallengeAddViewModel() -> ChallengeAddViewModel {
        let createChallengeUseCase = CreateChallengeUseCase(repository: commandRepo)
        let userRepo = UserRepository(apiClient: apiClient)
        let fetchPointsUseCase = FetchPointsUseCase(repository: userRepo)
        return ChallengeAddViewModel(
            createChallengeUseCase: createChallengeUseCase,
            fetchPointsUseCase: fetchPointsUseCase
        )
    }

    public func makeChallengeListViewModel() -> ChallengeListViewModel {
        let useCase = FetchChallengeListUseCase(repository: queryRepo)
        return ChallengeListViewModel(fetchChallengeListUseCase: useCase)
    }

    public func makeActiveChallengeListViewModel() -> ActiveChallengeListViewModel {
        let useCase = FetchActiveChallengesUseCase(repository: queryRepo)
        return ActiveChallengeListViewModel(fetchActiveChallengesUseCase: useCase)
    }

    public func makeChallengeDetailViewModel(challengeId: Int) -> ChallengeDetailViewModel {
        let fetchDetailUseCase = FetchChallengeDetailUseCase(repository: queryRepo)
        let checkEnrollmentUseCase = CheckChallengeEnrollmentUseCase(repository: queryRepo)
        let fetchRecommendedUseCase = FetchRecommendedChallengesUseCase(repository: queryRepo)
        let fetchFeedThumbnailsUseCase = FetchChallengeFeedThumbnailsUseCase(repository: queryRepo)
        let joinChallengeUseCase = JoinChallengeUseCase(repository: commandRepo)
        
        return ChallengeDetailViewModel(
            challengeId: challengeId,
            fetchDetailUseCase: fetchDetailUseCase,
            checkEnrollmentUseCase: checkEnrollmentUseCase,
            fetchRecommendedChallengesUseCase: fetchRecommendedUseCase,
            fetchFeedThumbnailsUseCase: fetchFeedThumbnailsUseCase,
            joinChallengeUseCase: joinChallengeUseCase,
            queryRepo: queryRepo,
            feedRepo: feedRepo,
            commandRepo: commandRepo
        )
    }
    
    public func makeChallengeFeedDetailViewModel(feedId: Int) -> ChallengeFeedDetailViewModel {
        ChallengeFeedDetailViewModel(
            feedId: feedId,
            feedRepo: feedRepo,
            queryRepo: queryRepo,
            commandRepo: commandRepo
        )
    }

    public func makeMemberProfileViewModel(memberInfo: MemberInfo) -> MemberProfileViewModel {
        MemberProfileViewModel(memberInfo: memberInfo, feedRepo: feedRepo)
    }
    
    public func makeChallengeCertViewModel(
        challengeId: Int,
        challengeContext: ChallengeVerificationContext? = nil
    ) -> ChallengeCertViewModel {
        ChallengeCertViewModel(
            challengeId: challengeId,
            feedRepo: feedRepo,
            challengeContext: challengeContext
        )
    }
    
    public func makeSearchViewModel() -> SearchViewModel {
        let fetchRecommendedChallengesUseCase = FetchRecommendedChallengesUseCase(repository: queryRepo)
        return SearchViewModel(
            queryRepo: queryRepo,
            feedRepo: feedRepo,
            fetchRecommendedChallengesUseCase: fetchRecommendedChallengesUseCase
        )
    }
}
