//
//  ValidationError.swift
//  AuthDomain
//
//  Created by Seyoung Park on 9/1/25.
//

import Foundation

public enum ValidationError: LocalizedError {
    case emptyName
    case noKeywordsSelected
    case tooManyKeywords
    
    public var errorDescription: String? {
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
