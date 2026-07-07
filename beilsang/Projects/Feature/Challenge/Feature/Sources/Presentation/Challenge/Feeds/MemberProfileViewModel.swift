//
//  MemberProfileViewModel.swift
//  ChallengeFeature
//

import Foundation
import ChallengeDomain
import ModelsShared

public struct ProfileBadge: Identifiable, Sendable {
    public let id: String
    public let title: String
    /// DesignSystem 번들의 컬러(획득) 아이콘 이름
    public let iconName: String

    public init(id: String, title: String, iconName: String) {
        self.id = id
        self.title = title
        self.iconName = iconName
    }
}

@MainActor
public final class MemberProfileViewModel: ObservableObject {
    @Published public var feeds: [FeedListItem] = []
    @Published public var isLoading = false
    @Published public var hasNext = false

    // MARK: - 프로필 통계
    // TODO: 멤버 프로필 통계 API 연동 시 실제 값으로 교체
    @Published public var feedCount: Int = 0
    @Published public var successCount: Int = 0
    @Published public var failedCount: Int = 0

    // MARK: - 획득 배지 (획득한 배지만 노출)
    // TODO: 멤버 배지 조회 API 연동 시 실제 값으로 교체 (현재는 미리보기용 목 데이터)
    @Published public var activityBadges: [ProfileBadge] = []
    @Published public var challengeBadges: [ProfileBadge] = []

    public let memberInfo: MemberInfo

    private let feedRepo: FeedRepositoryProtocol
    private var currentPage = 0
    private let pageSize = 10

    public init(memberInfo: MemberInfo, feedRepo: FeedRepositoryProtocol) {
        self.memberInfo = memberInfo
        self.feedRepo = feedRepo
        self.activityBadges = Self.mockActivityBadges
        self.challengeBadges = Self.mockChallengeBadges
        // TODO: 멤버 프로필 통계 API 연동 시 실제 값으로 교체 (현재는 미리보기용 목 데이터)
        self.feedCount = 20
        self.successCount = 5
        self.failedCount = 0
        self.feeds = Self.mockFeeds
    }

    public func loadFeeds(reset: Bool = false) async {
        guard !isLoading else { return }

        if reset {
            currentPage = 0
            hasNext = false
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let response = try await feedRepo.fetchMemberFeeds(
                memberId: memberInfo.memberId,
                page: currentPage,
                size: pageSize
            )

            if reset {
                // API 결과가 비어있으면 미리보기용 목 데이터를 유지
                feeds = response.content.isEmpty ? Self.mockFeeds : response.content
            } else {
                feeds.append(contentsOf: response.content)
            }

            hasNext = response.hasNext
            if response.hasNext {
                currentPage += 1
            }
        } catch {
            #if DEBUG
            print("❌ 참여자 피드 로딩 실패: \(error.localizedDescription)")
            #endif
        }
    }

    // MARK: - Mock Data
    // 멤버 배지 조회 API가 준비되기 전까지 마이페이지 배지와 동일한 목록을 사용 (획득한 배지만)
    private static let mockActivityBadges: [ProfileBadge] = [
        ProfileBadge(id: "challengeStart", title: "챌린지 시작", iconName: "challengeStartOn"),
        ProfileBadge(id: "challengeCreate", title: "챌린지 제작", iconName: "challengeCreateOn"),
        ProfileBadge(id: "challengeCert", title: "챌린지 인증", iconName: "challengeCertOn")
    ]

    private static let mockChallengeBadges: [ProfileBadge] = [
        ProfileBadge(id: "reusableCup", title: "다회용컵 챌린저", iconName: "reusableCupOn"),
        ProfileBadge(id: "refillStation", title: "리필스테이션 챌린저", iconName: "refillStationOn"),
        ProfileBadge(id: "reusableContainer", title: "다회용기 챌린저", iconName: "reusableContainerOn"),
        ProfileBadge(id: "ecoProduct", title: "친환경제품 챌린저", iconName: "ecoProductOn"),
        ProfileBadge(id: "plogging", title: "플로깅 챌린저", iconName: "ploggingOn"),
        ProfileBadge(id: "vegan", title: "비건 챌린저", iconName: "veganOn"),
        ProfileBadge(id: "publicTransit", title: "대중교통 챌린저", iconName: "publicTransitOn"),
        ProfileBadge(id: "bicycle", title: "자전거 챌린저", iconName: "bicycleOn"),
        ProfileBadge(id: "recycle", title: "재활용 챌린저", iconName: "recycleOn")
    ]

    // 멤버 피드 조회 API 결과가 비어있을 때 보여줄 미리보기용 목 데이터
    private static let mockFeeds: [FeedListItem] = (1...6).map { index in
        FeedListItem(
            feedId: index,
            memberId: 0,
            memberNickname: "닉네임",
            memberProfileUrl: "",
            challengeId: index,
            challengeTitle: "챌린지 \(index)",
            category: "ZERO_WASTE",
            content: "챌린지 인증 피드 \(index)",
            imageUrl: "https://picsum.photos/seed/beilsang\(index)/400/400",
            likeCount: index * 3,
            isLiked: false,
            createdAt: "2026-06-21T09:41:00.000"
        )
    }
}
