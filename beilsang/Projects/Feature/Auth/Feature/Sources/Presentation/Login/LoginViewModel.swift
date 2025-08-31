//
//  LoginViewModel.swift
//  AuthFeature
//
//  Created by Park Seyoung on 8/28/25.
//

import Foundation
import Combine
import SwiftUI
import ModelsShared

@MainActor
final class LoginViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var authState: AuthState = .unauthenticated
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Use Cases
    private let kakaoLoginUseCase: KakaoLoginUseCaseProtocol
    private let appleLoginUseCase: AppleLoginUseCaseProtocol
    private let signUpUseCase: SignUpUseCaseProtocol
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var isLoggedIn: Bool {
        if case .authenticated = authState {
            return true
        }
        return false
    }
    
    // MARK: - Initialization
    init(container: AuthContainer) {
        self.kakaoLoginUseCase = container.kakaoLoginUseCase
        self.appleLoginUseCase = container.appleLoginUseCase
        self.signUpUseCase = container.signUpUseCase
    }
    
    // MARK: - Public Methods
    func loginWithKakao(request: KakaoLoginRequest) {
        clearError()
        
        kakaoLoginUseCase.loginWithKakao(request: request)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleAuthState(state)
            }
            .store(in: &cancellables)
    }
    
    func loginWithApple(request: AppleLoginRequest) {
        clearError()
        
        appleLoginUseCase.loginWithApple(request: request)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleAuthState(state)
            }
            .store(in: &cancellables)
    }
    
    func signUp(request: SignUpRequest) {
        clearError()
        
        signUpUseCase.signUp(request: request)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleAuthState(state)
            }
            .store(in: &cancellables)
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Private Methods
    private func handleAuthState(_ state: AuthState) {
        authState = state
        
        switch state {
        case .unauthenticated:
            isLoading = false
            
        case .authenticating:
            isLoading = true
            errorMessage = nil
            
        case .authenticated:
            isLoading = false
            errorMessage = nil
            
        case .error(let error):
            isLoading = false
            errorMessage = error.localizedDescription
            
        case .tokenExpired:
            isLoading = false
            errorMessage = nil
        }
    }
}
