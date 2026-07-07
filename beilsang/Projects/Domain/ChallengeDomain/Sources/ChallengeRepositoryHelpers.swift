//
//  ChallengeRepositoryHelpers.swift
//  ChallengeDomain
//
//  Created by Seyoung Park on 12/26/25.
//

import Foundation
import ModelsShared
import NetworkCore

// MARK: - Error Mapping
public enum ChallengeError: Error, LocalizedError {
    case invalidRequest
    case networkError(String)
    case serverError(String)
    case notImplemented
    
    public var errorDescription: String? {
        switch self {
        case .invalidRequest:
            return "잘못된 요청입니다."
        case .networkError(let message):
            return "네트워크 오류: \(message)"
        case .serverError(let message):
            return "서버 오류: \(message)"
        case .notImplemented:
            return "아직 구현되지 않았습니다."
        }
    }
}

// MARK: - Error Handler
public struct ChallengeErrorHandler {
    public static func handleError(_ error: Error) -> (title: String, message: String) {
        if let challengeError = error as? ChallengeError {
            switch challengeError {
            case .networkError(let message):
                return ("네트워크 오류", message)
            case .serverError(let message):
                return ("서버 오류", message)
            case .invalidRequest:
                return ("잘못된 요청", "다시 시도해주세요")
            case .notImplemented:
                return ("준비중", "곧 지원 예정입니다")
            }
        } else {
            return ("오류", error.localizedDescription)
        }
    }
}

public struct ChallengeRepositoryHelpers {
    public static func parseDate(_ dateString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter.date(from: dateString)
    }
}

