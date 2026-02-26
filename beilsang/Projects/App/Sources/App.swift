//
//  App.swift
//  App
//
//  Created by Seyoung Park on 9/27/25.
//

import SwiftUI
import NavigationShared
import DesignSystemShared
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct BeilsangApp: App {
    @StateObject private var appRouter = AppRouter()

    init() {
        FontRegister.registerFonts()
        
        // Kakao SDK 초기화
        KakaoSDK.initSDK(appKey: AppConfig.kakaoAppKey)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appRouter)
                .onOpenURL { url in
                    // 카카오 로그인 URL 핸들링
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                }
        }
    }
}

