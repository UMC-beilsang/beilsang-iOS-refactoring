//
//  NotificationType.swift
//  ModelsShared
//
//  Created by Park Seyoung on 12/18/25.
//

import Foundation

public enum NotificationType: String, Codable {
    case challengeStart = "CHALLENGE_START"
    case challengeReminder = "CHALLENGE_REMINDER"
    case newChallenge = "CHALLENGE_NEW"
    case recommendChallenge = "RECOMMEND_CHALLENGE"
    case weeklyResult = "WEEKLY_RESULT"
    case challengeResult = "CHALLENGE_RESULT"
    
    public var title: String {
        switch self {
        case .challengeStart:
            return "참여 챌린지 시작 알림"
        case .challengeReminder:
            return "챌린지 인증 알림"
        case .newChallenge:
            return "신규 챌린지 알림"
        case .recommendChallenge:
            return "추천 챌린지 알림"
        case .weeklyResult:
            return "주간 챌린지 결과"
        case .challengeResult:
            return "챌린지 결과"
        }
    }
}





