import SwiftUI
import AuthFeature
import ChallengeFeature
import DiscoverFeature
import MyPageFeature
import NavigationShared
import UIComponentsShared
import StorageCore
import Combine

private enum AppScreen {
    case splash      // 초기 로딩 (토큰 확인 중)
    case main
    case login
    case signup
}

struct RootView: View {
    @EnvironmentObject var appRouter: AppRouter
    @StateObject private var toastManager = ToastManager()
    
    let authContainer = AuthContainer()
    let challengeContainer = ChallengeContainer()
    let discoverContainer = DiscoverContainer()
    let myPageContainer = MyPageContainer()
    
    @State private var currentScreen: AppScreen = .splash
    @State private var cancellables = Set<AnyCancellable>()

    var body: some View {
        ZStack {
            contentView
                .animation(.easeInOut(duration: 0.3), value: currentScreen)
                .environmentObject(toastManager)
            
            // Toast overlay - 모든 화면 위에 표시 (하단)
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
        }
        .onAppear {
            checkAuthStatus()
        }
        .onChange(of: appRouter.shouldLogout) { _, shouldLogout in
            if shouldLogout {
                performLogout()
            }
        }
        .onChange(of: appRouter.shouldRevoke) { _, shouldRevoke in
            if shouldRevoke {
                performRevoke()
            }
        }
    }
    
    // MARK: - Logout
    private func performLogout() {
        authContainer.logoutUseCase.logout()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        #if DEBUG
                        print("❌ 로그아웃 실패: \(error)")
                        #endif
                        // 로그아웃 실패해도 로그인 화면으로 이동 (토큰은 UseCase에서 삭제됨)
                    }
                    // 성공/실패와 관계없이 로그인 화면으로 이동
                    currentScreen = .login
                    appRouter.shouldLogout = false
                    appRouter.selectedTab = 0
                    
                    // 화면 전환 후 토스트 표시
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        toastManager.show(
                            iconName: "toastCheckIcon",
                            message: "로그아웃했어요"
                        )
                    }
                },
                receiveValue: { _ in
                    #if DEBUG
                    print("🚪 로그아웃 완료 - 로그인 화면으로")
                    #endif
                    currentScreen = .login
                    appRouter.shouldLogout = false
                    appRouter.selectedTab = 0
                    
                    // 화면 전환 후 토스트 표시
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        toastManager.show(
                            iconName: "toastCheckIcon",
                            message: "로그아웃했어요"
                        )
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Revoke (탈퇴)
    private func performRevoke() {
        authContainer.revokeUseCase.revoke()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        #if DEBUG
                        print("❌ 탈퇴 실패: \(error)")
                        #endif
                        toastManager.show(
                            iconName: "toastWarningIcon",
                            message: "탈퇴 처리 중 오류가 발생했습니다"
                        )
                        appRouter.shouldRevoke = false
                    }
                },
                receiveValue: { _ in
                    #if DEBUG
                    print("✅ 탈퇴 완료 - 로그인 화면으로")
                    #endif
                    // 탈퇴 성공 (토큰은 UseCase에서 삭제됨)
                    currentScreen = .login
                    appRouter.shouldRevoke = false
                    appRouter.selectedTab = 0
                    
                    // 화면 전환 후 토스트 표시
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        toastManager.show(
                            iconName: "toastCheckIcon",
                            message: "탈퇴가 완료되었어요"
                        )
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Auth Check
    private func checkAuthStatus() {
        authContainer.tokenStorage.getToken()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        // Keychain 에러 → 로그인 화면으로
                        currentScreen = .login
                    }
                },
                receiveValue: { token in
                    if let token = token, !token.accessToken.isEmpty {
                        #if DEBUG
                        print("✅ 저장된 토큰 발견 - 메인 화면으로")
                        #endif
                        currentScreen = .main
                    } else {
                        #if DEBUG
                        print("❌ 토큰 없음 - 로그인 화면으로")
                        #endif
                        currentScreen = .login
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch currentScreen {
        case .splash:
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                ProgressView()
            }
            .transition(.opacity)
            
        case .main:
            MainTabView(
                challengeContainer: challengeContainer,
                discoverContainer: discoverContainer,
                myPageContainer: myPageContainer,
                toastManager: toastManager
            )
            .transition(.opacity)
            
        case .login:
            LoginView(
                container: authContainer,
                onLoginSuccess: { isNewMember in
                    if isNewMember {
                        #if DEBUG
                        print("🆕 신규 회원 - 회원가입 화면으로")
                        #endif
                        currentScreen = .signup
                    } else {
                        #if DEBUG
                        print("✅ 기존 회원 - 메인 화면으로")
                        #endif
                        currentScreen = .main
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
                    currentScreen = .main
                }
            )
            .transition(.move(edge: .trailing))
        }
    }
}
