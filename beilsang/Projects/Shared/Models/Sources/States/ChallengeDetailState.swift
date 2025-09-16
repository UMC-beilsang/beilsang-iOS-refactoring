//
//  ChallengeDetailState.swift
//  ModelsShared
//
//  Created by Seyoung Park on 9/9/25.
//

import Foundation

public enum ChallengeDetailState {
    case enrolled(EnrolledState)
    case notEnrolled(NotEnrolledState)

    public enum EnrolledState {
        case beforeStart                    // 신청 완료 but 챌린지 시작 전
        case inProgress(canCertify: Bool)   // 챌린지 기간 이내 (오늘 인증 가능 여부)
        case calculating                    // 챌린지 기간 종료, 정산중
        case finished(success: Bool)        // 정산 완료 (성공/실패)
    }

    public enum NotEnrolledState {
        case canApply    // 챌린지 기간 이내 -> 참여 가능
        case applied     // 신청만 완료된 상태 (결제 전 등)
        case closed      // 챌린지 기간 이외 -> 모집 마감
    }
}
