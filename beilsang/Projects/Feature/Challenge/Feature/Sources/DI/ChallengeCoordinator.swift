//
//  ChallengeCoordinator.swift
//  ChallengeFeature
//

import SwiftUI
import ModelsShared
import NavigationShared
import UIComponentsShared
import UtilityShared

@MainActor
public final class ChallengeCoordinator: ObservableObject, ChallengeCoordinatable, ChallengeViewFactory, ChallengePresentationCoordinator {
    @Published public var path: [ChallengeRoute] = []
    
    // FullScreenCover 관리
    @Published public var presentedFeed: FeedPresentation? = nil
    @Published public var presentedChallenge: ChallengePresentation? = nil
    @Published public var presentedSearch: SearchPresentation? = nil
    @Published public var presentedChallengeAdd: ChallengeAddPresentation? = nil
    @Published public var presentedNotification: NotificationPresentation? = nil
    
    // Dependencies
    private let container: ChallengeContainer
    private weak var toastManager: ToastManager?
    
    public struct FeedPresentation: Identifiable {
        public let id: Int
    }
    
    public struct ChallengePresentation: Identifiable {
        public let id: Int
    }
    
    public struct SearchPresentation: Identifiable {
        public let id = UUID()
    }
    
    public struct ChallengeAddPresentation: Identifiable {
        public let id = UUID()
    }
    
    public struct NotificationPresentation: Identifiable {
        public let id = UUID()
    }
    
    public init(container: ChallengeContainer, toastManager: ToastManager? = nil) {
        self.container = container
        self.toastManager = toastManager
    }
    
    // MARK: - ChallengeCoordinatable 
    public func showChallengeDetail(id: Int) {
        path.append(.challengeDetail(id: id))
    }
    
    public func showFeedDetail(id: Int) {
        path.append(.feedDetail(id: id))
    }
    
    // MARK: - Internal Navigation
    public func navigateToChallengeList(category: Keyword) {
        path.append(.challengeList(category: category))
    }
    
    public func navigateToDetail(id: Int) {
        path.append(.challengeDetail(id: id))
    }
    
    public func navigateToCreate(step: Int = 0) {
        path.append(.challengeCreate(step: step))
    }
    
    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    public func popToRoot() {
        path.removeAll()
    }
    
    // MARK: - FullScreenCover Presentation
    public func presentFeed(id: Int) {
        presentedFeed = FeedPresentation(id: id)
    }
    
    public func presentChallenge(id: Int) {
        presentedChallenge = ChallengePresentation(id: id)
    }
    
    public func presentSearch() {
        presentedSearch = SearchPresentation()
    }
    
    public func presentChallengeAdd() {
        presentedChallengeAdd = ChallengeAddPresentation()
    }
    
    public func dismissFeed() {
        presentedFeed = nil
    }
    
    public func dismissChallenge() {
        presentedChallenge = nil
    }
    
    public func dismissSearch() {
        presentedSearch = nil
    }
    
    public func dismissChallengeAdd() {
        presentedChallengeAdd = nil
    }
    
    public func presentNotification() {
        presentedNotification = NotificationPresentation()
    }
    
    public func dismissNotification() {
        presentedNotification = nil
    }
    
    // MARK: - View Factory Methods
    @ViewBuilder
    public func makeChallengeDetailView(challengeId: Int) -> some View {
        ChallengeDetailView(
            viewModel: container.makeChallengeDetailViewModel(challengeId: challengeId)
        )
        .environmentObject(self)
        .ifLet(toastManager) { view, manager in
            view.environmentObject(manager)
        }
    }
    
    @ViewBuilder
    public func makeFeedDetailView(feedId: Int) -> some View {
        ChallengeFeedDetailView(
            viewModel: container.makeChallengeFeedDetailViewModel(feedId: feedId)
        )
        .environmentObject(self)
        .ifLet(toastManager) { view, manager in
            view.environmentObject(manager)
        }
    }
    
    @ViewBuilder
    public func makeSearchView() -> some View {
        SearchView(
            viewModel: container.makeSearchViewModel(),
            challengeDetailViewBuilder: { [weak self] challengeId in
                self?.makeChallengeDetailView(challengeId: challengeId)
            },
            feedDetailViewBuilder: { [weak self] feedId in
                self?.makeFeedDetailView(feedId: feedId)
            }
        )
        .ifLet(toastManager) { view, manager in
            view.environmentObject(manager)
        }
    }
    
    @ViewBuilder
    public func makeChallengeAddView() -> some View {
        ChallengeAddView(viewModel: container.challengeAddViewModel)
            .environmentObject(self)
            .ifLet(toastManager) { view, manager in
                view.environmentObject(manager)
            }
    }
    
    // MARK: - Navigation Destination Factory
    @ViewBuilder
    public func makeDestinationView(for route: ChallengeRoute) -> some View {
        switch route {
        case .challengeList(let category):
            ChallengeListView(
                viewModel: container.makeChallengeListViewModel(),
                category: category
            )
            .environmentObject(self)
        case .challengeDetail(let id):
            makeChallengeDetailView(challengeId: id)
        case .challengeCreate:
            makeChallengeAddView()
        case .feedDetail(let feedId):
            makeFeedDetailView(feedId: feedId)
        }
    }
    
    // MARK: - ViewBuilder Helpers for Cross-Feature Integration
    // These methods return closures that can be used in ViewBuilder contexts
    // Used by MyPageFeature and other features that need Challenge views
    public func makeChallengeDetailViewBuilder() -> (Int) -> AnyView {
        { [weak self] challengeId in
            if let self = self {
                AnyView(self.makeChallengeDetailView(challengeId: challengeId))
            } else {
                AnyView(EmptyView())
            }
        }
    }
    
    public func makeFeedDetailViewBuilder() -> (Int) -> AnyView {
        { [weak self] feedId in
            if let self = self {
                AnyView(self.makeFeedDetailView(feedId: feedId))
            } else {
                AnyView(EmptyView())
            }
        }
    }
}

// Helper extension for optional environment object
extension View {
    @ViewBuilder
    func ifLet<T: ObservableObject>(_ optional: T?, transform: (Self, T) -> some View) -> some View {
        if let value = optional {
            transform(self, value)
        } else {
            self
        }
    }
}

public enum ChallengeRoute: Hashable {
    case challengeList(category: Keyword)
    case challengeDetail(id: Int)
    case feedDetail(id: Int)
    case challengeCreate(step: Int)
}
