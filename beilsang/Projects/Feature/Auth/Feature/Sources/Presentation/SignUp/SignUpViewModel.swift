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

struct Terms {
    var service: Bool = false
    var privacy: Bool = false
    var marketing: Bool = false
    
    var requiredAgreed: Bool { service && privacy }
    var allAgreed: Bool { service && privacy && marketing }
}

struct DisabledReason {
    let message: String
    let icon: String
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
        // TODO: URL 끼워넣깅
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


@MainActor
final class SignUpViewModel: ObservableObject {
    // MARK: - Published
    @Published var currentStep: SignUpStep = .terms
    @Published var name: String = ""
    @Published var selectedKeyword: Keyword? = nil
    @Published var selectedMotto: Motto? = nil
    @Published var isLoading: Bool = false
    @Published var alert: AlertState?
    @Published var terms = Terms()
    @Published var showTermsSheet: TermsType?
    @Published var navigationDirection: NavigationDirection = .forward
    @Published var userInfo = UserInfo() {
        didSet {
            if oldValue.nickname != userInfo.nickname {
                if userInfo.nickname.isEmpty {
                    nicknameState = .idle
                } else if nicknameState != .checking && nicknameState != .valid && nicknameState != .invalidDuplicate && nicknameState != .invalidFormat {
                    nicknameState = .typing
                }
            }
        }
    }
    @Published var referralInfo = ReferralInfo()
    @Published var nicknameState: NicknameState = .idle
    @Published var showGenderSheet: Bool = false
    @Published var showBirthDatePicker: Bool = false
    @Published var showAddressSearch: Bool = false
    
    // MARK: - Constants
    let availableKeywords = Keyword.allCases
    let availableMottos = Motto.allCases
    
    // MARK: - Init
    private let signUpUseCase: SignUpUseCaseProtocol
    private var signUpData: SignUpData
    private var cancellables = Set<AnyCancellable>()
    
    init(signUpData: SignUpData, container: AuthContainer) {
        self.signUpData = signUpData
        self.signUpUseCase = container.signUpUseCase
        self.name = signUpData.nickName
    }
    
    // MARK: - Step Navigation
    func nextStep() {
        guard let index = SignUpStep.allCases.firstIndex(of: currentStep),
              index + 1 < SignUpStep.allCases.count else { return }
        withAnimation(.easeInOut) {
            navigationDirection = .forward
            currentStep = SignUpStep.allCases[index + 1]
        }
    }
    
    func previousStep() {
        guard let index = SignUpStep.allCases.firstIndex(of: currentStep),
              index - 1 >= 0 else { return }
        withAnimation(.easeInOut) {
            navigationDirection = .backward
            currentStep = SignUpStep.allCases[index - 1]
        }
    }
    
    // MARK: - User Actions
    func toggleKeyword(_ keyword: Keyword) {
        selectedKeyword = (selectedKeyword == keyword) ? nil : keyword
    }
    
    func selectMotto(_ motto: Motto) {
        selectedMotto = (selectedMotto == motto) ? nil : motto
    }
    
    func toggleAllAgree() {
        let newValue = !(terms.service && terms.privacy)
        terms.service = newValue
        terms.privacy = newValue
        terms.marketing = newValue
    }
    
    func toggleServiceAgree() { terms.service.toggle() }
    func togglePrivacyAgree() { terms.privacy.toggle() }
    func toggleMarketingAgree() { terms.marketing.toggle() }
    
    func showServiceTerms() { showTermsSheet = .service }
    func showPrivacyTerms() { showTermsSheet = .privacy }
    func showMarketingTerms() { showTermsSheet = .marketing }
    func hideTermsSheet() { showTermsSheet = nil }
    
    func completeSignUp() {
        guard canCompleteSignUp else { return }
        
        // SignUpData 업데이트
        signUpData.nickName = userInfo.nickname
        signUpData.gender = userInfo.gender
        
        if let birth = userInfo.birthDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            signUpData.birth = formatter.string(from: birth)
        }
        
        signUpData.address = userInfo.address
        signUpData.keyword = selectedKeyword
        signUpData.resolution = selectedMotto?.rawValue ?? ""
        signUpData.discoveredPath = referralInfo.source
        signUpData.recommendNickname = referralInfo.recommender
        
        // 서버 Request 변환
        let request = signUpData.toRequest()
        
        signUpUseCase.signUp(request: request)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleSignUpState(state)
            }
            .store(in: &cancellables)
    }

    func checkNickname() {
        let nickname = userInfo.nickname.trimmingCharacters(in: .whitespaces)
        
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
        
        // TODO: API 연결
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if nickname.lowercased() == "taken" || nickname.lowercased() == "admin" {
                self.nicknameState = .invalidDuplicate
            } else {
                self.nicknameState = .valid
            }
        }
    }
    
    func clearError() { alert = nil }
    
    // MARK: - Focus State Management
    func nicknameFocusChanged(isFocused: Bool) {
        switch nicknameState {
        case .idle:
            if isFocused {
                nicknameState = .focused
            }
        case .focused:
            if !isFocused {
                nicknameState = .idle
            }
        case .typing:
            if !isFocused {
                nicknameState = .filled
            }
        case .filled:
            if isFocused {
                nicknameState = .typing
            }
        case .checking:
            break
        case .valid, .invalidFormat, .invalidDuplicate:
            if isFocused {
                // validation된 상태에서 다시 포커스되면 typing 상태로 변경
                nicknameState = userInfo.nickname.isEmpty ? .focused : .typing
            }
        }
    }
    
    // MARK: - 버튼 상태
    var isNextEnabled: Bool {
        switch currentStep {
        case .terms:
            return terms.requiredAgreed
        case .keywords:
            return selectedKeyword != nil
        case .motto:
            return selectedMotto != nil
        case .info:
            return userInfo.isFilled && nicknameState == .valid
        case .referral:
            return referralInfo.source != ""
        case .complete:
            return canCompleteSignUp
        }
    }
    
    var disabledReason: DisabledReason? {
        switch currentStep {
        case .terms:
            return terms.requiredAgreed ? nil :
                DisabledReason(message: "필수 약관에 모두 동의해 주세요", icon: "toastCheckIcon")
            
        case .keywords:
            return selectedKeyword != nil ? nil :
                DisabledReason(message: "키워드를 선택해 주세요", icon: "toastCheckIcon")
            
        case .motto:
            return selectedMotto != nil ? nil :
                DisabledReason(message: "다짐을 한 가지 선택해 주세요", icon: "toastCheckIcon")
            
        case .info:
            guard nicknameState == .valid else {
                return DisabledReason(message: "닉네임 중복 확인이 필요합니다", icon: "warningIcon")
            }
            return userInfo.isFilled ? nil :
                DisabledReason(message: "정보를 모두 입력해 주세요", icon: "toastCheckIcon")
            
        case .referral:
            return referralInfo.source != "" ? nil :
                DisabledReason(message: "알게된 경로를 선택해 주세요", icon: "toastCheckIcon")
            
        case .complete:
            return canCompleteSignUp ? nil :
                DisabledReason(message: "회원가입 조건을 확인해 주세요", icon: "toastCheckIcon")
        }
    }
    
    var canCompleteSignUp: Bool {
        terms.requiredAgreed &&
        selectedKeyword != nil &&
        selectedMotto != nil &&
        userInfo.isFilled &&
        nicknameState == .valid
    }
    
    // MARK: - Private
    private func handleSignUpState(_ state: AuthState) {
        switch state {
        case .authenticating:
            isLoading = true
            alert = nil
        case .authenticated:
            isLoading = false
            // TODO: Navigate to main app
        case .error(let error):
            isLoading = false
            alert = AlertState(title: "회원가입 실패", message: error.localizedDescription)
        default:
            isLoading = false
        }
    }
}
