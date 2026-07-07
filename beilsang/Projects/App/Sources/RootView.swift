import SwiftUI
import AuthFeature
import ChallengeFeature
import DiscoverFeature
import MyPageFeature
import NavigationShared
import UIComponentsShared
import StorageCore
import NetworkCore
import Combine

struct RootView: View {
    @EnvironmentObject var appRouter: AppRouter
    @StateObject private var toastManager = ToastManager()
    
    let authContainer = AuthContainer()
    
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        ZStack {
            contentView
                .animation(.easeInOut(duration: 0.3), value: appRouter.currentScreen)
                .environmentObject(toastManager)
            
            // Toast overlay
            VStack {
                Spacer()
                if toastManager.isVisible, let toast = toastManager.toast {
                    ToastView(
                        iconName: toast.iconName,
                        message: toast.message
                    )
                    .padding(.bottom, UIScreen.main.bounds.height * 0.17)
                    .transition(.opacity)
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: toastManager.isVisible)
            .ignoresSafeArea(edges: .bottom)
            
            // 글로벌 로딩 오버레이
            if appRouter.isGlobalLoading {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .overlay {
                        DotsLoadingView(style: .overlay(message: "로딩 중..."))
                    }
                    .transition(.opacity)
                    .zIndex(2)
            }
        }
        .onReceive(appRouter.logoutEvent) { _ in
            performLogout()
        }
        .onReceive(appRouter.revokeEvent) { _ in
            performRevoke()
        }
        .onReceive(NotificationCenter.default.publisher(for: .authSessionExpired)) { _ in
            handleSessionExpired()
        }
    }
    
    // MARK: - Logout
    private func performLogout() {
        appRouter.isGlobalLoading = true
        
        Task {
            // 1. 서버 API 호출 (실패하더라도 에러 로그만 찍고 넘어감)
            do {
                try await authContainer.logoutUseCase.logout()
#if DEBUG
                print("🚪 로그아웃 API 성공")
#endif
            } catch {
#if DEBUG
                print("❌ 로그아웃 API 실패 (로컬 처리는 계속 진행): \(error)")
#endif
            }
            
            // 2. 성공/실패 여부와 상관없이 무조건 실행되는 공통 UI 처리
            await MainActor.run {
                appRouter.isGlobalLoading = false
                appRouter.currentScreen = .login
                appRouter.selectedTab = 0
            }
            
            // 3. 화면 전환 애니메이션을 위한 약간의 딜레이 후 토스트 띄우기
            try? await Task.sleep(nanoseconds: 300_000_000)
            
            await MainActor.run {
                toastManager.show(
                    iconName: "toastCheckIcon",
                    message: "로그아웃했어요"
                )
            }
        }
    }
    
    // MARK: - Revoke (탈퇴)
    private func performRevoke() {
        appRouter.isGlobalLoading = true
        
        Task {
            do {
                try await authContainer.revokeUseCase.revoke()
#if DEBUG
                print("✅ 탈퇴 완료 - 로그인 화면으로")
#endif
                
                await MainActor.run {
                    appRouter.isGlobalLoading = false
                    appRouter.currentScreen = .login
                    appRouter.selectedTab = 0
                }
                
                try? await Task.sleep(nanoseconds: 300_000_000)
                
                await MainActor.run {
                    toastManager.show(
                        iconName: "toastCheckIcon",
                        message: "탈퇴가 완료되었어요"
                    )
                }
            } catch {
#if DEBUG
                print("❌ 탈퇴 실패: \(error)")
#endif
                
                await MainActor.run {
                    appRouter.isGlobalLoading = false
                    toastManager.show(
                        iconName: "toastWarningIcon",
                        message: "탈퇴 처리 중 오류가 발생했습니다"
                    )
                }
            }
        }
    }
    
    // MARK: - Session Expired
    private func handleSessionExpired() {
        guard appRouter.currentScreen == .main else { return }
        
        appRouter.currentScreen = .login
        appRouter.selectedTab = 0
        
        Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            await MainActor.run {
                toastManager.show(
                    iconName: "toastWarningIcon",
                    message: "로그인이 만료되었어요. 다시 로그인해주세요"
                )
            }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch appRouter.currentScreen {
        case .main:
            MainTabView(
                challengeContainer: ChallengeContainer(),
                discoverContainer: DiscoverContainer(),
                myPageContainer: MyPageContainer(),
                toastManager: toastManager
            )
            .transition(.opacity)
            
        case .login:
            LoginView(
                container: authContainer,
                onLoginSuccess: { isNewMember in
                    if isNewMember {
#if DEBUG
                        print("🆕 신규 회원 - dev 빌드는 회원가입 생략 후 메인으로")
                        appRouter.currentScreen = .main
#else
                        appRouter.currentScreen = .signup
#endif
                    } else {
#if DEBUG
                        print("✅ 기존 회원 - 메인 화면으로")
#endif
                        appRouter.currentScreen = .main
                    }
                }
            )
            .transition(.opacity)
            
        case .signup:
            SignUpView(
                container: authContainer,
                onSignUpComplete: {
#if DEBUG
                    print("✅ 회원가입 완료 - 메인 화면으로")
#endif
                    appRouter.currentScreen = .main
                }
            )
            .transition(.move(edge: .trailing))
        }
    }
}
