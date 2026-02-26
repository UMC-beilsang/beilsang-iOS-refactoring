//
//  MyBadgeViewModel.swift
//  MyPageFeature
//
//  Created by Seyoung Park on 12/03/25.
//

import Foundation
import SwiftUI
import DesignSystemShared

public enum BadgeStage: String, Sendable {
    case sprout       // 새싹 (미획득)
    case seed         // 씨앗
    case tree         // 나무
    case forest       // 숲 (최고 등급)
}

public struct BadgeItem: Identifiable {
    public let id: String
    public let title: String
    public let iconOnName: String
    public let iconOffName: String
    public let stage: BadgeStage
}

@MainActor
public final class MyBadgeViewModel: ObservableObject {
    // MARK: - Representative Badge
    @Published public var representativeBadge: BadgeItem? = nil
    
    // MARK: - Activity Badges
    @Published public private(set) var activityBadges: [BadgeItem] = [
        BadgeItem(
            id: "challengeStart",
            title: "챌린지 시작",
            iconOnName: "challengeStartOn",
            iconOffName: "challengeStartOff",
            stage: .sprout
        ),
        BadgeItem(
            id: "challengeCreate",
            title: "챌린지 제작",
            iconOnName: "challengeCreateOn",
            iconOffName: "challengeCreateOff",
            stage: .seed
        ),
        BadgeItem(
            id: "challengeCert",
            title: "챌린지 인증",
            iconOnName: "challengeCertOn",
            iconOffName: "challengeCertOff",
            stage: .tree
        )
    ]
    
    // MARK: - Challenge Badges
    @Published public private(set) var challengeBadges: [BadgeItem] = [
        BadgeItem(
            id: "reusableCup",
            title: "다회용컵 챌린지",
            iconOnName: "reusableCupOn",
            iconOffName: "reusableCupOff",
            stage: .sprout
        ),
        BadgeItem(
            id: "refillStation",
            title: "리필스테이션 챌린지",
            iconOnName: "refillStationOn",
            iconOffName: "refillStationOff",
            stage: .seed
        ),
        BadgeItem(
            id: "reusableContainer",
            title: "다회용기 챌린지",
            iconOnName: "reusableContainerOn",
            iconOffName: "reusableContainerOff",
            stage: .seed
        ),
        BadgeItem(
            id: "ecoProduct",
            title: "친환경제품 챌린지",
            iconOnName: "ecoProductOn",
            iconOffName: "ecoProductOff",
            stage: .tree
        ),
        BadgeItem(
            id: "plogging",
            title: "플로깅 챌린지",
            iconOnName: "ploggingOn",
            iconOffName: "ploggingOff",
            stage: .sprout
        ),
        BadgeItem(
            id: "vegan",
            title: "비건 챌린지",
            iconOnName: "veganOn",
            iconOffName: "veganOff",
            stage: .seed
        ),
        BadgeItem(
            id: "publicTransit",
            title: "대중교통 챌린지",
            iconOnName: "publicTransitOn",
            iconOffName: "publicTransitOff",
            stage: .tree
        ),
        BadgeItem(
            id: "bicycle",
            title: "자전거 챌린지",
            iconOnName: "bicycleOn",
            iconOffName: "bicycleOff",
            stage: .sprout
        ),
        BadgeItem(
            id: "recycle",
            title: "재활용 챌린지",
            iconOnName: "recycleOn",
            iconOffName: "recycleOff",
            stage: .forest
        )
    ]
    
    // MARK: - Counts
    public var activityBadgeCountText: String {
        "\(activityBadges.count)"
    }
    
    public var challengeBadgeCountText: String {
        "\(challengeBadges.count)"
    }
}

// MARK: - BadgeStage Style Extension
extension BadgeStage {
    var displayName: String {
        switch self {
        case .sprout: return "새싹"
        case .seed: return "씨앗"
        case .tree: return "나무"
        case .forest: return "숲"
        }
    }
    
    var description: (String) -> String {
        switch self {
        case .sprout:
            return { "다음 배지 획득까지 \($0) 1개 인증하기" }
        case .seed:
            return { "다음 배지 획득까지 \($0) 3개 인증하기" }
        case .tree:
            return { "다음 배지 획득까지 \($0) 10개 인증하기" }
        case .forest:
            return { _ in "현재 최고 등급 배지입니다!" }
        }
    }
    
    @ViewBuilder
    func backgroundView(size: CGFloat, cornerRadius: CGFloat) -> some View {
        switch self {
        case .sprout:
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(ColorSystem.labelNormalDisable)
                .frame(width: size, height: size)
        case .seed:
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(ColorSystem.backgroundNormalAlternative)
                .frame(width: size, height: size)
        case .tree:
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(ColorSystem.primaryNeutral)
                .frame(width: size, height: size)
        case .forest:
            Image("badgeBackground", bundle: .designSystem)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
    }
}


