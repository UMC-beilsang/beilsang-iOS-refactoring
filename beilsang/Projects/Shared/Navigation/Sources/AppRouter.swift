//
//  AppRouter.swift
//  NavigationShared
//

import SwiftUI
import Combine

// Protocol
public protocol ChallengeCoordinatable: AnyObject {
    func showChallengeDetail(id: Int)
    func showFeedDetail(id: Int)
}

public protocol MyPageCoordinatable: AnyObject {
    func showProfile(userId: String)
}

public protocol ChallengeViewFactory: AnyObject {
    func makeChallengeDetailViewBuilder() -> (Int) -> AnyView
    func makeFeedDetailViewBuilder() -> (Int) -> AnyView
}

public protocol ChallengePresentationCoordinator: AnyObject {
    func presentFeed(id: Int)
    func presentChallenge(id: Int)
    func presentSearch()
    func presentNotification()
    func browseChallenges()
}

public struct ChallengePresentationCoordinatorKey: EnvironmentKey {
    public static let defaultValue: ChallengePresentationCoordinator? = nil
}

extension EnvironmentValues {
    public var challengePresentationCoordinator: ChallengePresentationCoordinator? {
        get { self[ChallengePresentationCoordinatorKey.self] }
        set { self[ChallengePresentationCoordinatorKey.self] = newValue }
    }
}

@MainActor
public final class AppRouter: ObservableObject {
    
    // MARK: - App Screen State
    public enum RootScreen {
        case main
        case login
        case signup
    }
    
    // 1. 상태: 현재 화면
    @Published public var currentScreen: RootScreen
    
    // 2. 상태: 글로벌 로딩
    @Published public var isGlobalLoading: Bool = false
    
    // 3. 상태: 선택된 탭
    @Published public var selectedTab: Int = 0
    
    // 한 번 발생하고 끝나는 단발성 액션은 Subject
    public let logoutEvent = PassthroughSubject<Void, Never>()
    public let revokeEvent = PassthroughSubject<Void, Never>()
    
    public weak var challengeCoordinator: ChallengeCoordinatable?
    public weak var myPageCoordinator: MyPageCoordinatable?

    public init(initialScreen: RootScreen = .login) {
        self.currentScreen = initialScreen
    }
    
    // MARK: - Auth Actions
    public func logout() {
        logoutEvent.send()
    }
    
    public func revoke() {
        revokeEvent.send()
    }

    // MARK: - Tab
    public func switchTab(to index: Int) {
        selectedTab = index
    }

    // MARK: - Coordination
    public func showChallengeDetail(id: Int) {
        selectedTab = 2
        challengeCoordinator?.showChallengeDetail(id: id)
    }

    public func showFeedDetail(id: Int) {
        selectedTab = 2
        challengeCoordinator?.showFeedDetail(id: id)
    }

    public func showProfile(userId: String) {
        selectedTab = 3
        myPageCoordinator?.showProfile(userId: userId)
    }
}
