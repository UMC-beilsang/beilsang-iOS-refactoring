//
//  MyPageCoordinator.swift
//  MyPageFeature
//
//  Created by Seyoung Park on 11/26/25.
//

import SwiftUI
import NavigationShared
import UIComponentsShared
import UtilityShared

public enum MyPageRoute: Hashable {
    case profileEdit
    case settings
    case point
    case badge
}

@MainActor
public final class MyPageCoordinator: ObservableObject, MyPageCoordinatable {
    @Published public var path = NavigationPath()
    
    // FullScreenCover 관리
    @Published public var presentedMyChallengeList: MyChallengeListPresentation? = nil
    @Published public var presentedMyFeedList: MyFeedListPresentation? = nil
    @Published public var presentedFavoriteChallengeList: FavoriteChallengeListPresentation? = nil
    
    // Dependencies
    public let container: MyPageContainer
    private weak var toastManager: ToastManager?
    private weak var challengeViewFactory: ChallengeViewFactory?
    
    public struct MyChallengeListPresentation: Identifiable {
        public let id = UUID()
        public let tabIndex: Int
    }
    
    public struct MyFeedListPresentation: Identifiable {
        public let id = UUID()
    }
    
    public struct FavoriteChallengeListPresentation: Identifiable {
        public let id = UUID()
    }
    
    public init(
        container: MyPageContainer,
        toastManager: ToastManager? = nil,
        challengeViewFactory: ChallengeViewFactory? = nil
    ) {
        self.container = container
        self.toastManager = toastManager
        self.challengeViewFactory = challengeViewFactory
    }
    
    // MARK: - Navigation
    public func navigateToProfileEdit() {
        path.append(MyPageRoute.profileEdit)
    }
    
    public func navigateToSettings() {
        path.append(MyPageRoute.settings)
    }
    
    public func navigateToPoint() {
        path.append(MyPageRoute.point)
    }
    
    public func navigateToBadge() {
        path.append(MyPageRoute.badge)
    }
    
    public func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    public func popToRoot() {
        path.removeLast(path.count)
    }
    
    // MARK: - MyPageCoordinatable
    public func showProfile(userId: String) {
        // TODO: 다른 사용자 프로필 표시
        print("Show profile for user: \(userId)")
    }
    
    // MARK: - FullScreenCover Presentation
    public func presentMyChallengeList(tabIndex: Int = 0) {
        presentedMyChallengeList = MyChallengeListPresentation(tabIndex: tabIndex)
    }
    
    public func presentMyFeedList() {
        presentedMyFeedList = MyFeedListPresentation()
    }
    
    public func presentFavoriteChallengeList() {
        presentedFavoriteChallengeList = FavoriteChallengeListPresentation()
    }
    
    public func dismissMyChallengeList() {
        presentedMyChallengeList = nil
    }
    
    public func dismissMyFeedList() {
        presentedMyFeedList = nil
    }
    
    public func dismissFavoriteChallengeList() {
        presentedFavoriteChallengeList = nil
    }
    
    // MARK: - View Factory Methods
    @ViewBuilder
    public func makeMyChallengeListView(initialTab: Int) -> some View {
        if let challengeViewFactory = challengeViewFactory {
            MyChallengeListView(
                viewModel: container.makeMyChallengeListViewModel(),
                initialTab: initialTab,
                challengeDetailViewBuilder: challengeViewFactory.makeChallengeDetailViewBuilder()
            )
        } else {
            // Fallback if challengeViewFactory is not set
            MyChallengeListView(
                viewModel: container.makeMyChallengeListViewModel(),
                initialTab: initialTab,
                challengeDetailViewBuilder: { _ in EmptyView() }
            )
        }
    }
    
    @ViewBuilder
    public func makeMyFeedListView() -> some View {
        if let challengeViewFactory = challengeViewFactory {
            MyFeedListView(
                viewModel: container.makeMyFeedListViewModel(),
                feedDetailViewBuilder: challengeViewFactory.makeFeedDetailViewBuilder()
            )
        } else {
            // Fallback if challengeViewFactory is not set
            MyFeedListView(
                viewModel: container.makeMyFeedListViewModel(),
                feedDetailViewBuilder: { _ in AnyView(EmptyView()) }
            )
        }
    }
    
    @ViewBuilder
    public func makeFavoriteChallengeListView() -> some View {
        if let challengeViewFactory = challengeViewFactory {
            FavoriteChallengeListView(
                viewModel: container.makeFavoriteChallengeListViewModel(),
                challengeDetailViewBuilder: challengeViewFactory.makeChallengeDetailViewBuilder()
            )
        } else {
            // Fallback if challengeViewFactory is not set
            FavoriteChallengeListView(
                viewModel: container.makeFavoriteChallengeListViewModel(),
                challengeDetailViewBuilder: { _ in EmptyView() }
            )
        }
    }
    
    // MARK: - Navigation Destination Factory
    @ViewBuilder
    public func makeDestinationView(for route: MyPageRoute) -> some View {
        switch route {
        case .profileEdit:
            ProfileEditView(viewModel: container.makeProfileEditViewModel())
                .environmentObject(self)
                .ifLet(toastManager) { view, manager in
                    view.environmentObject(manager)
                }
        case .settings:
            // TODO: 설정 화면
            Text("설정")
        case .point:
            PointView(viewModel: container.makePointViewModel())
        case .badge:
            MyBadgeView(viewModel: container.makeMyBadgeViewModel())
        }
    }
}

// Helper extension for optional environment object
extension View {
    @ViewBuilder
    public func ifLet<T: ObservableObject>(_ optional: T?, transform: (Self, T) -> some View) -> some View {
        if let value = optional {
            transform(self, value)
        } else {
            self
        }
    }
}

