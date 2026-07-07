//
//  ChallengeExampleApp.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/1/25.
//

import SwiftUI
import DesignSystemShared
import UIComponentsShared
import ModelsShared
import NavigationShared
import ChallengeFeature
import ChallengeDomain

@main
struct ChallengeExampleApp: App {
    init() {
        FontRegister.registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            PhotoVerificationExampleRootView()
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var appRouter: AppRouter
    
    private let container: ChallengeContainer
    @StateObject private var coordinator: ChallengeCoordinator
    
    init() {
        let container = ChallengeContainer()
        self.container = container
        _coordinator = StateObject(wrappedValue: ChallengeCoordinator(container: container))
    }
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {            HomeView(container: container)
                .environmentObject(coordinator)
                .navigationDestination(for: ChallengeRoute.self) { route in
                    destinationView(for: route)
                        .environmentObject(coordinator)
                }
        }
        .onAppear {
            appRouter.challengeCoordinator = coordinator
        }
    }
    
    @ViewBuilder
    private func destinationView(for route: ChallengeRoute) -> some View {
        switch route {
        case .challengeList(let category):
            ChallengeListView(
                viewModel: container.makeChallengeListViewModel(),
                category: category
            )

        case .activeList:
            ActiveChallengeListView(
                viewModel: container.makeActiveChallengeListViewModel()
            )
            
        case .challengeDetail(let id):
            ChallengeDetailView(
                viewModel: container.makeChallengeDetailViewModel(challengeId: id)
            )
            
        case .feedDetail(let id):
            ChallengeFeedDetailView(
                viewModel: container.makeChallengeFeedDetailViewModel(feedId: id)
            )
            
        case .challengeCreate:
            ChallengeAddView(
                viewModel: container.makeChallengeAddViewModel()
            )
        }
    }
}
