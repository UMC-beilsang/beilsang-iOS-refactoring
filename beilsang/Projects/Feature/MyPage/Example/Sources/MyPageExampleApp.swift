//
//  MyPageExampleApp.swift
//  DiscoverFeature
//
//  Created by Seyoung Park on 10/8/25.
//

import SwiftUI
import DesignSystemShared
import UIComponentsShared
import ModelsShared
import ChallengeDomain
import MyPageFeature
import NavigationShared

@main
struct MyPageExampleApp: App {
    @StateObject private var toastManager = ToastManager()
    @StateObject private var appRouter = AppRouter()
    
    init() {
        FontRegister.registerFonts()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(toastManager)
                .environmentObject(appRouter)
        }
    }
}

struct ContentView: View {
    @StateObject private var router = MyPageRouter()
    @StateObject private var globalManager = GlobalPresentationManager()
    private let container = MyPageContainer()
    
    var body: some View {
        NavigationStack(path: $router.navigationPath) {
            MyPageView(viewModel: container.myPageViewModel)
                .navigationDestination(for: MyPageRoute.self) { route in
                    router.view(for: route)
                }
        }
        .environmentObject(router)
        .environmentObject(globalManager)
    }
}
