//
//  App.swift
//  App
//
//  Created by Seyoung Park on 9/27/25.
//

import SwiftUI
import NavigationShared

@main
struct BeilsangApp: App {
    @StateObject private var appRouter = AppRouter()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appRouter)
        }
    }
}
