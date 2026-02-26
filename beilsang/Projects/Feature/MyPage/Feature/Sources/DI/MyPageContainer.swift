//
//  MyPageContainer.swift
//  MyPageFeature
//
//  Created by Seyoung Park on 11/26/25.
//

import Foundation
import Alamofire
import UserDomain
import ChallengeDomain
import StorageCore
import NetworkCore
import ModelsShared

@MainActor
public final class MyPageContainer {
    // MARK: - Properties
    public let myPageViewModel: MyPageViewModel
    
    private let userRepository: UserRepositoryProtocol
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
        let userRepo = UserRepository(apiClient: apiClient)
        let challengeRepo = ChallengeRepository(apiClient: apiClient)
        
        self.userRepository = userRepo
        self.challengeRepository = challengeRepo
        
        // User UseCases
        let fetchUserProfileUseCase = FetchUserProfileUseCase(repository: userRepo)
        let fetchMyFeedsUseCase = FetchMyFeedsUseCase(repository: userRepo)
        let updateProfileUseCase = UpdateProfileUseCase(repository: userRepo)
        let updateProfileImageUseCase = UpdateProfileImageUseCase(repository: userRepo)
        let fetchPointsUseCase = FetchPointsUseCase(repository: userRepo)
        
        // MyPage Root ViewModel
        self.myPageViewModel = MyPageViewModel(
            fetchUserProfileUseCase: fetchUserProfileUseCase,
            fetchMyFeedsUseCase: fetchMyFeedsUseCase
        )
    }
    
    // MARK: - Convenience Init
    public convenience init() {
        let baseURL = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String ?? ""
        self.init(baseURL: baseURL)
    }
    
    // MARK: - Factory Methods
    public func makeProfileEditViewModel() -> ProfileEditViewModel {
        let fetchUserProfileUseCase = FetchUserProfileUseCase(repository: userRepository)
        let updateProfileUseCase = UpdateProfileUseCase(repository: userRepository)
        let updateProfileImageUseCase = UpdateProfileImageUseCase(repository: userRepository)
        
        return ProfileEditViewModel(
            fetchUserProfileUseCase: fetchUserProfileUseCase,
            updateProfileUseCase: updateProfileUseCase,
            updateProfileImageUseCase: updateProfileImageUseCase
        )
    }
    
    public func makeMyChallengeListViewModel() -> MyChallengeListViewModel {
        return MyChallengeListViewModel(repository: challengeRepository)
    }
    
    public func makeMyFeedListViewModel() -> MyFeedListViewModel {
        let fetchMyFeedsUseCase = FetchMyFeedsUseCase(repository: userRepository)
        return MyFeedListViewModel(fetchMyFeedsUseCase: fetchMyFeedsUseCase)
    }
    
    public func makePointViewModel() -> PointViewModel {
        let fetchPointsUseCase = FetchPointsUseCase(repository: userRepository)
        return PointViewModel(fetchPointsUseCase: fetchPointsUseCase)
    }
    
    public func makeFavoriteChallengeListViewModel() -> FavoriteChallengeListViewModel {
        return FavoriteChallengeListViewModel(repository: challengeRepository)
    }
    
    public func makeMyBadgeViewModel() -> MyBadgeViewModel {
        MyBadgeViewModel()
    }
}

