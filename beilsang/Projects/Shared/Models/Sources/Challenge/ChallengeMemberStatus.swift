//
//  ChallengeMemberStatus.swift
//  ModelsShared
//
//  Created by Seyoung Park on 12/18/25.
//

import Foundation

/// 챌린지 참여자의 상태
public enum ChallengeMemberStatus: String, Codable, Sendable {
    case success = "SUCCESS"       // 챌린지 성공 (정산 완료)
    case fail = "FAIL"            // 챌린지 실패 (정산 완료)
    case ongoing = "ONGOING"      // 챌린지 진행 중
    case notYet = "NOT_YET"       // 참여 완료 but 챌린지 시작 전
    case notJoined = "NOT_JOINED" // 미참여
}







