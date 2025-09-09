//
//  SignUpUseCase.swift
//  AuthDomain
//
//  Created by Park Seyoung on 8/28/25.
//

import Foundation
import Combine
import ModelsShared
import Alamofire

public protocol SignUpUseCaseProtocol {
    func signUp(request: SignUpRequest) -> AnyPublisher<AuthState, Never>
    func validateSignUpData(_ data: SignUpRequest) -> ValidationResult
}

public final class SignUpUseCase: SignUpUseCaseProtocol {
    private let repository: AuthRepositoryProtocol
    
    public init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }
    
    public func signUp(request: SignUpRequest) -> AnyPublisher<AuthState, Never> {
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
    
    public func validateSignUpData(_ data: SignUpRequest) -> ValidationResult {
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
