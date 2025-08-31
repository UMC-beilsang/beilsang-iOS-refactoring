//
//  SignUpUseCase.swift
//  AuthFeature
//
//  Created by Park Seyoung on 8/28/25.
//

import Foundation
import Combine
import ModelsShared
import Alamofire

protocol SignUpUseCaseProtocol {
    func signUp(request: SignUpRequest) -> AnyPublisher<AuthState, Never>
    func validateSignUpData(_ data: SignUpRequest) -> ValidationResult
}

final class SignUpUseCase: SignUpUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    
    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }
    
    func signUp(request: SignUpRequest) -> AnyPublisher<AuthState, Never> {
        let validation = validateSignUpData(request)
        
        if !validation.isValid {
            let errorMessage = validation.errors.first?.localizedDescription ?? "입력 정보를 확인해주세요."
            return Just(.error(.unknownError(errorMessage))).eraseToAnyPublisher()
        }
        
        return Just(.authenticating)
            .append(
                repository.signUp(request: request)
                    .map { _ in AuthState.authenticated }
                    .catch { error -> AnyPublisher<AuthState, Never> in
                        Just(.error(error)).eraseToAnyPublisher()
                    }
            )
            .eraseToAnyPublisher()
    }
    
    func validateSignUpData(_ data: SignUpRequest) -> ValidationResult {
        var errors: [ValidationError] = []
        
        if data.nickName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append(.emptyName)
        }
        
        if data.keyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append(.noKeywordsSelected)
        }
        
        let keywords = data.keyword.split(separator: ",")
        if keywords.count > 5 {
            errors.append(.tooManyKeywords)
        }
        
        return ValidationResult(isValid: errors.isEmpty, errors: errors)
    }
}

struct ValidationResult {
    let isValid: Bool
    let errors: [ValidationError]
}

enum ValidationError: LocalizedError {
    case emptyName
    case noKeywordsSelected
    case tooManyKeywords
    
    var errorDescription: String? {
        switch self {
        case .emptyName:
            return "닉네임을 입력해주세요."
        case .noKeywordsSelected:
            return "관심 키워드를 최소 1개 선택해주세요."
        case .tooManyKeywords:
            return "관심 키워드는 최대 5개까지 선택 가능합니다."
        }
    }
}
