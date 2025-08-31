//
//  AuthExampleApp.swift
//  AuthFeature
//
//  Created by Park Seyoung on 8/28/25.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth
import AuthFeature
import DesignSystemShared
import UIComponentsShared
import ModelsShared
@testable import AuthFeature

@main
struct AuthExampleApp: App {
    @StateObject private var toastManager = ToastManager()
    private let authContainer: AuthContainer
    
    init() {
        KakaoSDK.initSDK(appKey: AuthExampleAppConfig.kakaoAppKey)
        FontRegister.registerFonts()
        self.authContainer = AuthContainer(baseURL: AuthExampleAppConfig.baseURL)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(container: authContainer)
                .environmentObject(toastManager)
                .onOpenURL { url in
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                }
        }
    }
}

struct ContentView: View {
    private let container: AuthContainer

    init(container: AuthContainer) {
        self.container = container
    }

    var body: some View {
        SignUpView(
            signUpData: {
                var data = SignUpData()
                data.accessToken = "test_id"         
                data.nickName = ""
                return data
            }(),
            container: container
        )        .withToast()
    }
}
