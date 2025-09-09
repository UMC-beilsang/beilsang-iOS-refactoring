//
//  Challenge.swift
//  ChallengeDomain
//
//  Created by Seyoung Park on 9/2/25.
//

import Foundation
import ModelsShared
import UtilityShared

public struct Challenge: Identifiable, Equatable {
    public let id: String
    public let title: String
    public let description: String
    public let category: String
    public let status: String
    
    public let progress: Double       // 달성률 (%)
    
    public let startDate: Date
    public let endDate: Date
    
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
    public let createdAt: Date   
    
    public init(
        id: String,
        title: String,
        description: String,
        category: String,
        status: String,
        progress: Double,
        startDate: Date,
        endDate: Date,
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
        createdAt: Date
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.status = status
        self.progress = progress
        self.startDate = startDate
        self.endDate = endDate
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
        self.createdAt = createdAt
    }
}

public extension Challenge {
    init(from response: ChallengeResponse) {
        self.id = response.challengeId
        self.title = response.title
        self.description = response.description
        self.category = response.category
        self.status = response.status
        
        self.progress = response.progress
        self.startDate = response.startDate
        self.endDate = response.endDate
        
        self.currentParticipants = response.currentParticipants
        self.maxParticipants = response.maxParticipants
        self.depositAmount = response.depositAmount
        self.certificationMethod = response.certificationMethod
        self.infoImageUrls = response.infoImageUrls
        self.certImageUrls = response.certImageUrls
        self.thumbnailImageUrl = response.infoImageUrls.first
        self.isLiked = response.isLiked
        self.likeCount = response.likeCount
        self.isParticipating = response.isParticipating
        self.createdAt = response.createdAt
    }
}
