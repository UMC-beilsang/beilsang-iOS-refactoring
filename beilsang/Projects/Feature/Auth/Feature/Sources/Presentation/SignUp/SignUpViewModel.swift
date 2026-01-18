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
    case keywords
    case motto
    case info
    case referral
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

    @Published var signUpData: SignUpData = .init() {
        didSet {
            let newNickname = signUpData.userInfo.nickname
            let oldNickname = oldValue.userInfo.nickname
            if oldNickname != newNickname {
                if newNickname.isEmpty {
                    if nicknameState == .focused {
                        nicknameState = .focused
                    } else {
                        nicknameState = .idle
                    }
                } else if nicknameState == .focused || nicknameState == .typing {
                    nicknameState = .typing
                } else if nicknameState != .checking && nicknameState != .valid {
                    nicknameState = .filled
                }
            }
        }
    }

    @Published var nicknameState: NicknameState = .idle
    @Published var showGenderSheet: Bool = false
    @Published var showBirthDatePicker: Bool = false
    @Published var showAddressSearch: Bool = false

    // MARK: - Constants
    let availableKeywords = Keyword.allCases
    let availableMottos = Motto.allCases

    // MARK: - Dependencies
    private let signUpUseCase: SignUpUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(signUpData: SignUpData = .init(), container: AuthContainer) {
        self.signUpData = signUpData
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
        if currentStep == .referral {
            completeSignUp()
        } else {
            nextStep()
        }
    }

    // MARK: - User Actions
    func toggleKeyword(_ keyword: Keyword) {
        signUpData.keyword = (signUpData.keyword == keyword) ? nil : keyword
    }

    func selectMotto(_ motto: Motto) {
        signUpData.motto = (signUpData.motto == motto) ? nil : motto
    }

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
    func completeSignUp() {
        guard canCompleteSignUp else { return }

        signUpUseCase.signUp(data: signUpData)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleSignUpState(state)
            }
            .store(in: &cancellables)
    }

    // MARK: - Nickname Check
    func checkNickname() {
        let nickname = signUpData.userInfo.nickname.trimmingCharacters(in: .whitespaces)

        guard !nickname.isEmpty else {
            nicknameState = .invalidFormat
            return
        }

        guard (2...15).contains(nickname.count) else {
            nicknameState = .invalidFormat
            return
        }

        let regex = "^[가-힣a-zA-Z0-9]+$"
        if nickname.range(of: regex, options: .regularExpression) == nil {
            nicknameState = .invalidFormat
            return
        }

        nicknameState = .checking

        // API로 닉네임 중복 확인
        signUpUseCase.checkNickname(nickname)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] (completion: Subscribers.Completion<AuthError>) in
                    guard let self = self else { return }
                    if case .failure(let error) = completion {
                        #if DEBUG
                        print("❌ Nickname check error: \(error)")
                        #endif
                        // 에러 발생 시 형식 오류로 처리
                        self.nicknameState = .invalidFormat
                    }
                },
                receiveValue: { [weak self] (isAvailable: Bool) in
                    guard let self = self else { return }
                    if isAvailable {
                        self.nicknameState = .valid
                    } else {
                        self.nicknameState = .invalidDuplicate
                    }
                }
            )
            .store(in: &cancellables)
    }

    func clearError() { alert = nil }

    // MARK: - Step Validation
    var isNextEnabled: Bool {
        switch currentStep {
        case .terms:
            return terms.requiredAgreed
        case .keywords:
            return signUpData.keyword != nil
        case .motto:
            return signUpData.motto != nil
        case .info:
            return signUpData.userInfo.isFilled && nicknameState == .valid
        case .referral:
            return signUpData.referralInfo.source != nil
        case .complete:
            return terms.requiredAgreed &&
                   signUpData.keyword != nil &&
                   signUpData.motto != nil &&
                   signUpData.userInfo.isFilled &&
                   nicknameState == .valid
        }
    }

    var canCompleteSignUp: Bool {
        terms.requiredAgreed &&
        signUpData.keyword != nil &&
        signUpData.motto != nil &&
        signUpData.userInfo.isFilled &&
        nicknameState == .valid
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
