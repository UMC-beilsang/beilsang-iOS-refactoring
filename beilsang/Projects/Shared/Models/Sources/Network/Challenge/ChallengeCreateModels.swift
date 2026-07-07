import Foundation

// MARK: - Request
public struct ChallengeCreateRequest: Codable, Sendable {
    public let title: String
    public let startDate: String
    public let period: Period
    public let totalGoalDay: Int
    public let category: String
    public let details: String
    public let notes: [String]?
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
        challengeNotes: [String]?,
        joinPoint: Int
    ) {
        self.title = title
        self.startDate = startDate
        self.period = period
        self.totalGoalDay = totalGoalDay
        self.category = category
        self.details = details
        self.notes = challengeNotes
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
    public let challengeNotes: [String]?
    public let period: String
    public let totalGoalDay: Int
    public let attendeeCount: Int
    public let countLikes: Int
    public let collectedPoint: Int
    
}
