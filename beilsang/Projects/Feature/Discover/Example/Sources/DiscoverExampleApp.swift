//
//  DiscoverExampleApp.swift
//  DiscoverFeature
//
//  Created by Seyoung Park on 10/8/25.
//

import SwiftUI
import DesignSystemShared
import UIComponentsShared
import ModelsShared
import ChallengeDomain
import DiscoverFeature
import NavigationShared

@main
struct DiscoverExampleApp: App {
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
    @StateObject private var router = DiscoverRouter()
    private let container = DiscoverContainer()
    
    var body: some View {
        DiscoverView(container: container, router: router)
    }
}
