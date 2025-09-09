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
        case beforeStart
        case inProgress(canCertify: Bool)   // 오늘 인증 가능 여부
        case finished(success: Bool)        // 성공/실패
    }

    public enum NotEnrolledState {
        case canApply
        case applied
        case closed
    }
}
