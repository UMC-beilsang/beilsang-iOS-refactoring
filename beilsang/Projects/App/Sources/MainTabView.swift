//
//  MainTabView.swift
//  App
//
//  Created by Seyoung Park on 9/27/25.
//

import SwiftUI
import NavigationShared
import DiscoverFeature
import ChallengeFeature
import MyPageFeature
import NotificationFeature
import NotificationDomain
import UIComponentsShared
import UtilityShared
import ModelsShared
import NetworkCore

struct MainTabView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var toastManager: ToastManager
    
    // 탭별 Coordinator
    @StateObject private var discoverCoordinator = DiscoverCoordinator()
    @StateObject private var challengeCoordinator: ChallengeCoordinator
    @StateObject private var myPageCoordinator: MyPageCoordinator
    
    // RootView에서 주입
    let challengeContainer: ChallengeContainer
    let discoverContainer: DiscoverContainer
    
    init(
        challengeContainer: ChallengeContainer,
        discoverContainer: DiscoverContainer,
        myPageContainer: MyPageContainer,
        toastManager: ToastManager
    ) {
        // Coordinator 초기화
        let coordinator = ChallengeCoordinator(container: challengeContainer, toastManager: toastManager)
        _challengeCoordinator = StateObject(wrappedValue: coordinator)
        
        // MyPageCoordinator 초기화 (ChallengeCoordinator를 ViewFactory로 전달)
        let myPageCoord = MyPageCoordinator(
            container: myPageContainer,
            toastManager: toastManager,
            challengeViewFactory: coordinator
        )
        _myPageCoordinator = StateObject(wrappedValue: myPageCoord)
        
        self.challengeContainer = challengeContainer
        self.discoverContainer = discoverContainer
    }
    
    private var shouldHideTabBar: Bool {
        !challengeCoordinator.path.isEmpty || !discoverCoordinator.path.isEmpty || !myPageCoordinator.path.isEmpty
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // MARK: - Content Views
            TabView(selection: $appRouter.selectedTab) {
                // 🏠 홈 탭
                homeTab
                    .tag(0)
                
                // 🔍 발견 탭
                discoverTab
                    .tag(1)
                
                // ✏️ 챌린지 만들기 탭
                Color.clear
                    .tag(2)
                
                // 👤 마이페이지 탭
                myPageTab
                    .tag(3)
            }
            
            // MARK: - Custom Tab Bar
            if !shouldHideTabBar {
                CustomTabBar(selectedTab: $appRouter.selectedTab)
                    .transition(.move(edge: .bottom))
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .onChange(of: appRouter.selectedTab) { oldValue, newValue in
            if newValue == 2 {
                challengeCoordinator.presentChallengeAdd()
                appRouter.selectedTab = oldValue
            }
        }
        .onChange(of: challengeCoordinator.presentedChallengeAdd) { _, newValue in
            if newValue == nil {
                KeyboardDismiss.perform()
            }
        }
        // Challenge Coordinator의 FullScreenCover 관리
        .fullScreenCover(item: $challengeCoordinator.presentedFeed) { feed in
            challengeCoordinator.makeFeedDetailView(feedId: feed.id)
                .toolbar(.hidden, for: .navigationBar)
        }
        .fullScreenCover(item: $challengeCoordinator.presentedMemberProfile) { profile in
            challengeCoordinator.makeMemberProfileView(memberInfo: profile.memberInfo)
                .toolbar(.hidden, for: .navigationBar)
        }
        .fullScreenCover(item: $challengeCoordinator.presentedChallenge) { challenge in
            challengeCoordinator.makeChallengeDetailView(challengeId: challenge.id)
                .toolbar(.hidden, for: .navigationBar)
        }
        .fullScreenCover(item: $challengeCoordinator.presentedSearch) { _ in
            challengeCoordinator.makeSearchView()
        }
        .fullScreenCover(item: $challengeCoordinator.presentedChallengeAdd) { _ in
            challengeCoordinator.makeChallengeAddView()
        }
        .fullScreenCover(item: $challengeCoordinator.presentedNotification) { _ in
            let notificationRepository = NotificationRepository(
                apiClient: APIClient(baseURL: "https://api.beilsang.com")
            )
            NotificationView(viewModel: NotificationViewModel(
                fetchNotificationsUseCase: FetchNotificationsUseCase(repository: notificationRepository),
                markAsReadUseCase: MarkNotificationAsReadUseCase(repository: notificationRepository),
                deleteNotificationsUseCase: DeleteNotificationsUseCase(repository: notificationRepository),
                deleteAllNotificationsUseCase: DeleteAllNotificationsUseCase(repository: notificationRepository)
            ))
            .environmentObject(toastManager)
            .toolbar(.hidden, for: .navigationBar)
        }
        // MyPage Coordinator의 FullScreenCover 관리
        .fullScreenCover(item: $myPageCoordinator.presentedMyChallengeList) { presentation in
            myPageCoordinator.makeMyChallengeListView(initialTab: presentation.tabIndex)
                .environment(\.challengePresentationCoordinator, challengeCoordinator)
        }
        .fullScreenCover(item: $myPageCoordinator.presentedMyFeedList) { _ in
            myPageCoordinator.makeMyFeedListView()
                .environment(\.challengePresentationCoordinator, challengeCoordinator)
        }
        .fullScreenCover(item: $myPageCoordinator.presentedFavoriteChallengeList) { _ in
            myPageCoordinator.makeFavoriteChallengeListView()
                .environment(\.challengePresentationCoordinator, challengeCoordinator)
        }
        .onAppear {
            // 기본 탭바 숨기기
            UITabBar.appearance().isHidden = true
            
            appRouter.challengeCoordinator = challengeCoordinator
            appRouter.myPageCoordinator = myPageCoordinator
            challengeCoordinator.onNavigateToMyPage = {
                appRouter.switchTab(to: 3)
            }
            challengeCoordinator.onBrowseChallenges = {
                myPageCoordinator.dismissMyFeedList()
                myPageCoordinator.dismissMyChallengeList()
                myPageCoordinator.dismissFavoriteChallengeList()
                appRouter.switchTab(to: 0)
                challengeCoordinator.navigateToChallengeList(category: .all)
            }
        }
    }
    
    // MARK: - Home Tab
    private var homeTab: some View {
        NavigationStack(path: $challengeCoordinator.path) {
            HomeView(container: challengeContainer)
                .navigationDestination(for: ChallengeRoute.self) { route in
                    switch route {
                    case .challengeList(let category):
                        ChallengeListView(
                            viewModel: challengeContainer.makeChallengeListViewModel(),
                            category: category
                        )
                        .environmentObject(challengeCoordinator)
                    case .challengeDetail(let id):
                        ChallengeDetailView(
                            viewModel: challengeContainer.makeChallengeDetailViewModel(challengeId: id)
                        )
                        .environmentObject(challengeCoordinator)
                    case .challengeCreate:
                        ChallengeAddView(
                            viewModel: challengeContainer.makeChallengeAddViewModel()
                        )
                        .environmentObject(challengeCoordinator)
                    case .activeList:
                        ActiveChallengeListView(
                            viewModel: challengeContainer.makeActiveChallengeListViewModel()
                        )
                        .environmentObject(challengeCoordinator)
                    case .feedDetail(let feedId):
                        ChallengeFeedDetailView(
                            viewModel: challengeContainer.makeChallengeFeedDetailViewModel(feedId: feedId)
                        )
                        .environmentObject(toastManager)
                        .environmentObject(challengeCoordinator)
                    }
                }
                .environmentObject(challengeCoordinator)
        }
    }
    
    // MARK: - Discover Tab
    private var discoverTab: some View {
        NavigationStack(path: $discoverCoordinator.path) {
            DiscoverView(
                container: discoverContainer,
                coordinator: discoverCoordinator
            )
            .environment(\.challengePresentationCoordinator, challengeCoordinator)
        }
    }
    
    // MARK: - MyPage Tab
    private var myPageTab: some View {
        NavigationStack(path: $myPageCoordinator.path) {
            MyPageView(viewModel: myPageCoordinator.container.myPageViewModel)
                .navigationDestination(for: MyPageRoute.self) { route in
                    myPageCoordinator.makeDestinationView(for: route)
                        .ifLet(appRouter) { view, router in
                            view.environmentObject(router)
                        }
                }
                .environmentObject(myPageCoordinator)
                .environment(\.challengePresentationCoordinator, challengeCoordinator)
        }
    }
}


