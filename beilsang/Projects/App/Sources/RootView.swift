//
//  RootView.swift
//  App
//
//  Created by Seyoung Park on 9/27/25.
//

import SwiftUI
import AuthFeature
import NavigationShared

struct RootView: View {
    @EnvironmentObject var appRouter: AppRouter
    @State private var isLoggedIn = false

    var body: some View {
        if isLoggedIn {
            MainTabView()
        } else {
            LoginView(onLoginSuccess: {
                isLoggedIn = true
            })
            .fullScreenCover(isPresented: $appRouter.showSignup) {
                SignUpView()
            }
        }
    }
}
