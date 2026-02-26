//
//  ChallengePopupType.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/10/25.
//

import UIComponentsShared
import DesignSystemShared

public enum ChallengePopupType {
    case register
    case participate(requiredPoint: Int, currentPoint: Int, periodText: String)
    case certify
    case settlement(secondsRemaining: Int)
    case report
    case insufficientPoint(required: Int, current: Int)

    var style: PopupView.Style {
        switch self {
        case .register:
            return .alert(
                message: "모든 챌린지 정보 작성이 끝났나요?\n한 번 등록된 챌린지는 수정 및 삭제가 불가능합니다.",
                subMessage: nil
            )

        case let .participate(requiredPoint, currentPoint, periodText):
            return .content(
                type: .cert(minRequiredPoint: requiredPoint, numberOfCert: 7, certUnit: periodText)
            )
        case .certify:
            return .alert(
                message: "해당 게시물을 정말 신고하시겠습니까?",
                subMessage: nil
            )

        case let .settlement(secondsRemaining):
            return .alertCountdown(message: "헤헤", seconds: secondsRemaining)

        case .report:
            return .alert(
                message: "해당 챌린지를 정말 신고하시겠습니까?",
                subMessage: nil
            )

        case let .insufficientPoint(required, current):
            return .content(
                type: .point(minRequiredPoint: required, earnedPoint: current)
            )
        }
    }

    /// 팝업 제목
    var title: String {
        switch self {
        case .register: return "챌린지 등록하기"
        case .participate: return "챌린지 참여하기"
        case .certify: return "챌린지 인증 신고하기"
        case .settlement: return "챌린지 정산 중"
        case .report: return "챌린지 신고하기"
        case .insufficientPoint: return "보유 포인트 부족"
        }
    }

    var actions: (primary: PopupAction?, secondary: PopupAction?) {
        switch self {
        case .register:
            return (
                .init(title: "챌린지 만들기", handler: {}),
                .init(title: "취소", handler: {})
            )
        case .participate:
            return (
                .init(title: "참여하기", handler: {}),
                .init(title: "취소", handler: {})
            )
        case .certify:
            return (
                .init(title: "신고하기", handler: {}),
                .init(title: "취소", handler: {})
            )
        case .settlement:
            return (
                .init(title: "확인", handler: {}),
                nil
            )
        case .report:
            return (
                .init(title: "신고하기", handler: {}),
                .init(title: "취소", handler: {})
            )
        case .insufficientPoint:
            return (
                .init(title: "포인트 충전하기", handler: {}),
                .init(title: "취소", handler: {})
            )
        }
    }
}
