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
    
    /// 리스트 등에서 "신청 마감" 표시 여부 (모집마감 또는 기간종료)
    public var isRegistrationClosed: Bool {
        if case .notEnrolled(.closed) = self { return true }
        return false
    }
    
    /// ChallengeDetailData + enrollment → UI 상태 변환
    public static func make(from detail: ChallengeDetailData, enrollment: ChallengeEnrollmentData) -> ChallengeDetailState {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        let startDate = dateFormatter.date(from: detail.startDate) ?? Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: dateFormatter.date(from: detail.finishDate) ?? Date.distantFuture) ?? Date.distantFuture

        // detail.status를 우선 판단 기준으로 사용
        // enrollment.isEnrolled만 믿으면 enrollment API 오류 시 참여자도 "참여하기"가 뜨는 버그 발생
        let isEffectivelyEnrolled = enrollment.isEnrolled
            || (detail.status != nil && detail.status != .notJoined)

        if isEffectivelyEnrolled {
            switch detail.status {
            case .notYet:
                return .enrolled(.beforeStart)
            case .ongoing:
                let canCertify = now >= startDate && now <= endDate
                return .enrolled(.inProgress(canCertify: canCertify))
            case .success:
                return .enrolled(.finished(success: true))
            case .fail:
                return .enrolled(.finished(success: false))
            case .notJoined, .none:
                if now > endDate {
                    return .enrolled(.calculating)
                } else {
                    return .enrolled(.inProgress(canCertify: true))
                }
            }
        } else {
            if now > endDate || detail.isRecruitmentClosed == true {
                return .notEnrolled(.closed)
            } else {
                return .notEnrolled(.canApply)
            }
        }
    }
}

