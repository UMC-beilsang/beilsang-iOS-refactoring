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

public struct ChallengeRepositoryHelpers {
    public static func mapAPIError(_ error: APIClientError) -> ChallengeError {
        switch error {
        case .invalidURL:
            return .invalidRequest
        case .http(let statusCode, _):
            return .networkError("HTTP \(statusCode)")
        case .decoding(let message, _):
            return .networkError(message)
        case .network(let error):
            return .networkError(error.localizedDescription)
        }
    }
    
    public static func mapToChallenge(from item: HallOfFameChallenge) -> Challenge {
        Challenge(
            id: item.challengeId,
            title: item.title,
            description: "",
            category: item.category,
            memberStatus: .ongoing,
            progress: 0,
            startDate: parseDate(item.startDate) ?? Date(),
            endDate: parseDate(item.finishDate) ?? Date(),
            author: "",
            currentParticipants: item.attendeeCount,
            maxParticipants: item.attendeeCount,
            depositAmount: 0,
            certificationMethod: "",
            infoImageUrls: item.infoImageUrls,
            certImageUrls: [],
            thumbnailImageUrl: item.infoImageUrls.first ?? "",
            isLiked: false,
            likeCount: item.likeCount,
            isParticipating: false,
            isRecruitmentClosed: true,
            createdAt: Date()
        )
    }
    
    public static func mapToChallenge(from item: ChallengeListItem) -> Challenge {
        Challenge(
            id: item.id,
            title: item.title,
            description: item.description,
            category: item.category,
            memberStatus: item.status,
            progress: 0,
            startDate: Date(),
            endDate: Date(),
            author: "",
            currentParticipants: item.participantCount,
            maxParticipants: item.participantCount,
            depositAmount: 0,
            certificationMethod: "",
            infoImageUrls: [item.imageUrl],
            certImageUrls: [],
            thumbnailImageUrl: item.imageUrl,
            isLiked: false,
            likeCount: item.likeCount,
            isParticipating: false,
            isRecruitmentClosed: item.isRecruitmentClosed,
            createdAt: Date()
        )
    }
    
    public static func mapToChallenge(from data: ChallengeDetailData) -> Challenge {
        Challenge(
            id: data.challengeId,
            title: data.title,
            description: data.description,
            category: data.category,
            memberStatus: data.status,
            progress: data.progress,
            startDate: parseDate(data.startDate) ?? Date(),
            endDate: parseDate(data.finishDate) ?? Date(),
            author: "",
            currentParticipants: data.attendeeCount,
            maxParticipants: data.attendeeCount,
            depositAmount: data.joinPoint,
            certificationMethod: data.challengeNotes.joined(separator: "\n"),
            infoImageUrls: data.infoImageUrls,
            certImageUrls: data.certImageUrls,
            thumbnailImageUrl: data.infoImageUrls.first,
            isLiked: false,
            likeCount: data.likeCount,
            isParticipating: !data.isJoinable,
            isRecruitmentClosed: data.isRecruitmentClosed,
            createdAt: Date()
        )
    }
    
    public static func mapToFeedDetail(from item: FeedItem, keyword: Keyword) -> ChallengeFeedDetail {
        ChallengeFeedDetail(
            id: item.feedId,
            feedUrl: item.feedUrl,
            day: item.day,
            userName: "User",
            userProfileImageUrl: nil,
            description: "",
            likeCount: 0,
            isLiked: false,
            challengeTags: [keyword.title],
            createdAt: Date(),
            isMyFeed: false
        )
    }
    
    public static func parseDate(_ dateString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter.date(from: dateString)
    }
}

