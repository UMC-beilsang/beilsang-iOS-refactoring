//
//  ChallengeCreateModels.swift
//  ModelsShared
//
//  Created by Seyoung Park on 11/25/25.
//

import Foundation

// MARK: - Request (multipart 'data' 필드로 전송됨)
public struct ChallengeCreateRequest: Codable, Sendable {
    public let title: String
    public let startDate: String // "YYYY-MM-DD"
    public let period: Period
    public let totalGoalDay: Int
    public let category: String
    public let details: String
    public let notes: [String]
    public let joinPoint: Int
    
    public enum Period: String, Codable {
        case week = "WEEK"
        case month = "MONTH"
        case custom = "CUSTOM"
    }
    
    public init(
        title: String,
        startDate: String,
        period: Period,
        totalGoalDay: Int,
        category: String,
        details: String,
        notes: [String],
        joinPoint: Int
    ) {
        self.title = title
        self.startDate = startDate
        self.period = period
        self.totalGoalDay = totalGoalDay
        self.category = category
        self.details = details
        self.notes = notes
        self.joinPoint = joinPoint
    }
}

// MARK: - Response
public struct ChallengeCreateResponse: Codable, Sendable {
    public let challengeId: Int
    public let category: String
    public let title: String
    public let startDate: String
    public let finishDate: String
    public let joinPoint: Int
    public let infoImageUrls: [String]
    public let certImageUrls: [String]
    public let details: String
    public let challengeNotes: [String]
    public let period: String
    public let totalGoalDay: Int
    public let attendeeCount: Int
    public let countLikes: Int
    public let collectedPoint: Int
    
    public init(
        challengeId: Int,
        category: String,
        title: String,
        startDate: String,
        finishDate: String,
        joinPoint: Int,
        infoImageUrls: [String],
        certImageUrls: [String],
        details: String,
        challengeNotes: [String],
        period: String,
        totalGoalDay: Int,
        attendeeCount: Int,
        countLikes: Int,
        collectedPoint: Int
    ) {
        self.challengeId = challengeId
        self.category = category
        self.title = title
        self.startDate = startDate
        self.finishDate = finishDate
        self.joinPoint = joinPoint
        self.infoImageUrls = infoImageUrls
        self.certImageUrls = certImageUrls
        self.details = details
        self.challengeNotes = challengeNotes
        self.period = period
        self.totalGoalDay = totalGoalDay
        self.attendeeCount = attendeeCount
        self.countLikes = countLikes
        self.collectedPoint = collectedPoint
    }
}

