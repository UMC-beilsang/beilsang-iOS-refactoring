//
//  SignUpViewModel.swift
//  AuthFeature
//
//  Created by Park Seyoung on 8/28/25.
//

import Foundation
import Combine
import ModelsShared
import SwiftUI
import AuthDomain
import UIComponentsShared

struct Terms {
    var service: Bool = false
    var privacy: Bool = false
    var marketing: Bool = false
    
    var requiredAgreed: Bool { service && privacy }
    var allAgreed: Bool { service && privacy && marketing }

    mutating func toggle(_ type: TermsType) {
        switch type {
        case .service: service.toggle()
        case .privacy: privacy.toggle()
        case .marketing: marketing.toggle()
        }
    }

    mutating func toggleAll() {
        let newValue = !requiredAgreed
        service = newValue
        privacy = newValue
        marketing = newValue
    }
}

public enum TermsType: Identifiable {
    public var id: String { title }
    case service
    case privacy
    case marketing
    
    public var title: String {
        switch self {
        case .service: return "서비스 이용약관"
        case .privacy: return "개인정보 처리방침"
        case .marketing: return "마케팅 정보 수신 동의"
        }
    }
    
    public var url: String {
        switch self {
        case .service: return "https://example.com/terms"
        case .privacy: return "https://example.com/privacy"
        case .marketing: return "https://example.com/marketing"
        }
    }
}

enum SignUpStep: Int, CaseIterable {
    case terms = 0
    case complete
}

enum NavigationDirection {
    case forward, backward
}

// MARK: - ViewModel

@MainActor
final class SignUpViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentStep: SignUpStep = .terms
    @Published var isLoading: Bool = false
    @Published var alert: AlertState?
    @Published var terms = Terms()
    @Published var showTermsSheet: TermsType?
    @Published var navigationDirection: NavigationDirection = .forward

    // MARK: - Dependencies
    private let signUpUseCase: SignUpUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(container: AuthContainer) {
        self.signUpUseCase = container.signUpUseCase
    }

    // MARK: - Step Navigation
    func nextStep() {
        guard let next = SignUpStep(rawValue: currentStep.rawValue + 1) else { return }
        withAnimation(.easeInOut) {
            navigationDirection = .forward
            currentStep = next
        }
    }

    func previousStep() {
        guard let prev = SignUpStep(rawValue: currentStep.rawValue - 1) else { return }
        withAnimation(.easeInOut) {
            navigationDirection = .backward
            currentStep = prev
        }
    }
    
    func nextOrComplete() {
        // 약관 동의 후 바로 회원가입 완료
        completeSignUpSimplified()
    }

    // MARK: - User Actions
    func toggleTerms(_ type: TermsType) {
        terms.toggle(type)
    }

    func toggleAllTerms() {
        terms.toggleAll()
    }

    func showTerms(_ type: TermsType) {
        showTermsSheet = type
    }

    func hideTermsSheet() {
        showTermsSheet = nil
    }

    // MARK: - Sign Up
    func completeSignUpSimplified() {
        guard terms.requiredAgreed else { return }
        
        signUpUseCase.signUpSimplified(marketingAgreed: terms.marketing)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleSignUpState(state)
            }
            .store(in: &cancellables)
    }

    func clearError() { alert = nil }

    // MARK: - Step Validation
    var isNextEnabled: Bool {
        return terms.requiredAgreed
    }

    // MARK: - Private
    private func handleSignUpState(_ state: AuthState) {
        switch state {
        case .loading:
            isLoading = true
            alert = nil
        case .authenticated:
            isLoading = false
            nextStep() 
        case .error(let error):
            isLoading = false
            alert = AlertState(title: "회원가입 실패", message: error.localizedDescription)
        default:
            isLoading = false
        }
    }
}
