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

@main
struct ChallengeExampleApp: App {
    
    init() {
        FontRegister.registerFonts()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        HomeView(container: ChallengeContainer())
    }
}
