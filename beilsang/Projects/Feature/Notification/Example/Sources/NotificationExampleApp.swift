//
//  NotificationExampleApp.swift
//  NotificationFeature
//
//  Created by Park Seyoung on 12/18/25.
//

import SwiftUI
import DesignSystemShared
import UIComponentsShared
import ModelsShared
import NavigationShared
import NotificationFeature
import NotificationDomain

@main
struct NotificationExampleApp: App {
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
    @EnvironmentObject var toastManager: ToastManager
    
    private let container = NotificationContainer()
    
    var body: some View {
        let coordinator = NotificationCoordinator(container: container)
        
        ZStack {
            NavigationStack {
                NotificationView(viewModel: container.makeNotificationViewModel())
                    .environmentObject(coordinator)
            }
            
            // Toast Overlay
            if toastManager.isVisible, let toast = toastManager.toast {
                VStack {
                    Spacer()
                    ToastView(
                        iconName: toast.iconName,
                        message: toast.message
                    )
                    .padding(.bottom, 48)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: toastManager.isVisible)
            }
        }
    }
}
