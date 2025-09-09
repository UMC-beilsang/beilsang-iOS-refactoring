//
//  Home.swift
//  ModelsShared
//
//  Created by Seyoung Park on 9/2/25.
//

import Foundation

public struct ChallengeResponse: Codable {
    public let challengeId: String
    public let title: String
    public let description: String
    public let category: String
    public let status: String
    public let progress: Double
    public let challengePeriod: String
    public let currentParticipants: Int
    public let maxParticipants: Int
    public let depositAmount: Int
    public let startDate: Date
    public let endDate: Date
    public let certificationMethod: String
    public let infoImageUrls: [String]
    public let certImageUrls: [String]
    public let isLiked: Bool
    public let likeCount: Int
    public let isParticipating: Bool
    public let createdAt: Date
    
    public init(
        challengeId: String,
        title: String,
        description: String,
        category: String,
        status: String,
        progress: Double,
        challengePeriod: String,       
        currentParticipants: Int,
        maxParticipants: Int,
        depositAmount: Int,
        startDate: Date,
        endDate: Date,
        certificationMethod: String,
        infoImageUrls: [String],
        certImageUrls: [String],
        isLiked: Bool,
        likeCount: Int,
        isParticipating: Bool,
        createdAt: Date
    ) {
        self.challengeId = challengeId
        self.title = title
        self.description = description
        self.category = category
        self.status = status
        self.progress = progress
        self.challengePeriod = challengePeriod
        self.currentParticipants = currentParticipants
        self.maxParticipants = maxParticipants
        self.depositAmount = depositAmount
        self.startDate = startDate
        self.endDate = endDate
        self.certificationMethod = certificationMethod
        self.infoImageUrls = infoImageUrls
        self.certImageUrls = certImageUrls
        self.isLiked = isLiked
        self.likeCount = likeCount
        self.isParticipating = isParticipating
        self.createdAt = createdAt
    }
}
