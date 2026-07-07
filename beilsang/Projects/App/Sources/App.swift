//
//  App.swift
//  App
//
//  Created by Seyoung Park on 9/27/25.
//

import SwiftUI
import Security
import NavigationShared
import DesignSystemShared
import ModelsShared
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct BeilsangApp: App {
    @StateObject private var appRouter: AppRouter

    init() {
        FontRegister.registerFonts()
        KakaoSDK.initSDK(appKey: AppConfig.kakaoAppKey)
        _appRouter = StateObject(wrappedValue: AppRouter(initialScreen: BeilsangApp.resolveInitialScreen()))
    }

    // Keychain을 동기로 읽어 첫 렌더링 화면을 결정 - 흰 화면 플래시 방지
    private static func resolveInitialScreen() -> AppRouter.RootScreen {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "com.beilsang.auth",
            kSecAttrAccount as String: "authToken",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var dataRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataRef)
        guard status == errSecSuccess,
              let data = dataRef as? Data,
              let token = try? JSONDecoder().decode(KeychainToken.self, from: data),
              !token.accessToken.isEmpty else {
            return .login
        }
        return .main
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appRouter)
                .onOpenURL { url in
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                }
        }
    }
}
