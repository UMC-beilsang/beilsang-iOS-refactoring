//
//  MainTabView.swift
//  App
//
//  Created by Seyoung Park on 9/27/25.
//

import SwiftUI
import NavigationShared
import HomeFeature
import DiscoverFeature
import LearnMoreFeature
import MyPageFeature

struct MainTabView: View {
    @EnvironmentObject var appRouter: AppRouter

    // 탭별 Router
    @StateObject private var homeRouter = HomeRouter()
    @StateObject private var discoverRouter = DiscoverRouter()
    @StateObject private var myPageRouter = MyPageRouter()

    var body: some View {
        TabView(selection: $appRouter.selectedTab) {
            NavigationStack(path: $homeRouter.path) {
                HomeView()
                    .navigationDestination(for: HomeRoute.self) { route in
                        switch route {
                        case .challengeDetail(let id):
                            ChallengeDetailView(id: id)
                        case .challengeCreate(let step):
                            ChallengeCreateView(step: step)
                        }
                    }
            }
            .environmentObject(homeRouter)
            .tabItem { Label("Home", systemImage: "house") }
            .tag(0)

            NavigationStack(path: $discoverRouter.path) {
                DiscoverView()
                    .navigationDestination(for: DiscoverRoute.self) { route in
                        switch route {
                        case .challengeDetail(let id):
                            ChallengeDetailView(id: id)
                        case .feed(let id):
                            ChallengeFeedDetailView(id: id)
                        }
                    }
            }
            .environmentObject(discoverRouter)
            .tabItem { Label("Discover", systemImage: "magnifyingglass") }
            .tag(1)

            NavigationStack {
                LearnMoreView()
            }
            .tabItem { Label("Learn", systemImage: "book") }
            .tag(2)

            NavigationStack(path: $myPageRouter.path) {
                MyPageView()
                    .navigationDestination(for: MyPageRoute.self) { route in
                        switch route {
                        case .profile(let userID):
                            ProfileDetailView(userID: userID)
                        }
                    }
            }
            .environmentObject(myPageRouter)
            .tabItem { Label("MyPage", systemImage: "person") }
            .tag(3)
        }
    }
}
