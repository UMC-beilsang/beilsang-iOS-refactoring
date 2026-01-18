//
//  AppRouter.swift
//  NavigationShared
//

import SwiftUI

// Protocol
public protocol ChallengeCoordinatable: AnyObject {
    func showChallengeDetail(id: Int)
    func showFeedDetail(id: Int)
}

public protocol MyPageCoordinatable: AnyObject {
    func showProfile(userId: String)
}

// Protocol for Challenge View Factory
// Allows other features to create Challenge views without direct dependency
public protocol ChallengeViewFactory: AnyObject {
    func makeChallengeDetailViewBuilder() -> (Int) -> AnyView
    func makeFeedDetailViewBuilder() -> (Int) -> AnyView
}

// Protocol for Challenge Presentation (FullScreenCover)
// Allows other features to present Challenge screens without direct dependency
public protocol ChallengePresentationCoordinator: AnyObject {
    func presentFeed(id: Int)
    func presentChallenge(id: Int)
    func presentSearch()
}

// EnvironmentKey for ChallengePresentationCoordinator
// Allows using protocol in @Environment without direct module dependency
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
    // Tab
    @Published public var selectedTab: Int = 0
    
    // Auth State (RootView에서 감지)
    @Published public var shouldLogout: Bool = false
    @Published public var shouldRevoke: Bool = false
    
    public weak var challengeCoordinator: ChallengeCoordinatable?
    public weak var myPageCoordinator: MyPageCoordinatable?

    public init() {}
    
    // MARK: - Logout
    public func logout() {
        shouldLogout = true
    }
    
    // MARK: - Revoke (탈퇴)
    public func revoke() {
        shouldRevoke = true
    }

    // MARK: - Tab
    public func switchTab(to index: Int) {
        selectedTab = index
    }

    // MARK: - Coordination
    public func showChallengeDetail(id: Int) {
        // Challenge 탭으로 이동 + Detail 보여주기
        selectedTab = 2  // Challenge 탭
        challengeCoordinator?.showChallengeDetail(id: id)
    }

    public func showFeedDetail(id: Int) {
        selectedTab = 2
        challengeCoordinator?.showFeedDetail(id: id)
    }

    public func showProfile(userId: String) {
        selectedTab = 3  // MyPage 탭
        myPageCoordinator?.showProfile(userId: userId)
    }
}
