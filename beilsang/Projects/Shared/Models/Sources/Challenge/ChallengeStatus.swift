//
//  ChallengeStatus.swift
//  ModelsShared
//
//  Created by Seyoung Park on 12/18/25.
//

import Foundation

/// 챌린지 자체의 상태 (시작/진행/종료)
public enum ChallengeStatus: String, Codable, Sendable {
    case notYet = "NOT_YET"           // 챌린지 시작 전
    case inProgress = "IN_PROGRESS"   // 챌린지 진행 중
    case end = "END"                  // 챌린지 종료
}







