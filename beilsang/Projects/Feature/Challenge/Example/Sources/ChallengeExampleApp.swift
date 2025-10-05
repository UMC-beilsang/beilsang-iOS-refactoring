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
@testable import ChallengeFeature
import ChallengeDomain

@main
struct ChallengeExampleApp: App {
    @StateObject private var toastManager = ToastManager()
    
    init() {
        FontRegister.registerFonts()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .withToast()
                .environmentObject(toastManager)
        }
    }
}

struct ContentView: View {
    @StateObject private var router = ChallengeRouter()
    private let container = ChallengeContainer()
    
    var body: some View {
        HomeView(container: container, router: router)
    }
}
