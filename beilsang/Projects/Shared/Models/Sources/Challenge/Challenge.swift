//
//  Challenge.swift
//  ModelsShared
//
//  Created by Seyoung Park on 9/2/25.
//
// 

import Foundation

public struct Challenge: Identifiable, Equatable {
    public let id: Int
    public let title: String
    public let description: String
    public let category: String
    public let memberStatus: ChallengeMemberStatus?
     
    public let progress: Double
    
    public let startDate: Date
    public let endDate: Date
    
    public let author: String
    
    public let currentParticipants: Int
    public let maxParticipants: Int
    public let depositAmount: Int
    public let certificationMethod: String
    
    public let infoImageUrls: [String]
    public let certImageUrls: [String]
    public let thumbnailImageUrl: String?
    
    public let isLiked: Bool
    public let likeCount: Int
    public let isParticipating: Bool
    public let isRecruitmentClosed: Bool  // 서버에서 계산된 값
    public let createdAt: Date   
    
    public init(
        id: Int,
        title: String,
        description: String,
        category: String,
        memberStatus: ChallengeMemberStatus?,
        progress: Double,
        startDate: Date,
        endDate: Date,
        author: String,
        currentParticipants: Int,
        maxParticipants: Int,
        depositAmount: Int,
        certificationMethod: String,
        infoImageUrls: [String],
        certImageUrls: [String],
        thumbnailImageUrl: String?,
        isLiked: Bool,
        likeCount: Int,
        isParticipating: Bool,
        isRecruitmentClosed: Bool,
        createdAt: Date
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.memberStatus = memberStatus
        self.progress = progress
        self.startDate = startDate
        self.endDate = endDate
        self.author = author
        self.currentParticipants = currentParticipants
        self.maxParticipants = maxParticipants
        self.depositAmount = depositAmount
        self.certificationMethod = certificationMethod
        self.infoImageUrls = infoImageUrls
        self.certImageUrls = certImageUrls
        self.thumbnailImageUrl = thumbnailImageUrl
        self.isLiked = isLiked
        self.likeCount = likeCount
        self.isParticipating = isParticipating
        self.isRecruitmentClosed = isRecruitmentClosed
        self.createdAt = createdAt
    }
}

public extension Challenge {
    /// 챌린지의 상세 상태를 계산
    var detailState: ChallengeDetailState {
        let now = Date()
        
        if isParticipating {
            // 참여중인 경우 - ChallengeMemberStatus 기준
            switch memberStatus {
            case .notYet:
                return .enrolled(.beforeStart)
            case .ongoing:
                // TODO: 오늘 인증 가능 여부는 서버 데이터 필요
                let canCertify = true // 임시값
                return .enrolled(.inProgress(canCertify: canCertify))
            case .success:
                return .enrolled(.finished(success: true))
            case .fail:
                return .enrolled(.finished(success: false))
            case .notJoined, .none:
                // 정산 중 상태 (status가 없을 때)
                if now > endDate {
                    return .enrolled(.calculating)
                } else {
                    return .enrolled(.inProgress(canCertify: true))
                }
            }
        } else {
            // 참여하지 않은 경우
            if now > endDate {
                return .notEnrolled(.closed)
            } else {
                return .notEnrolled(.canApply)
            }
        }
    }
}
