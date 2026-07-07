//
//  ChallengeItemViewModel.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/3/25.
//

import Foundation
import ChallengeDomain
import ModelsShared

public struct ChallengeItemViewModel: Identifiable {
    public let id: Int
    public let title: String
    public let thumbnailImageUrl: String
    public let progressText: String
    public let author: String?
    public let isRecruitmentClosed: Bool
    public let createdAt: Date
    public let startDate: Date
    
    public init(challengeListItem: ChallengeListItem, isClosed: Bool) {
        self.id = challengeListItem.challengeId
        self.title = challengeListItem.title
        self.thumbnailImageUrl = ""
        self.progressText = "0%"
        self.author = ""
        self.isRecruitmentClosed = isClosed
        self.createdAt = Date()
        self.startDate = ISO8601DateFormatter().date(from: challengeListItem.startDate) ?? Date()
    }

    public init(challengeItem: ChallengeItem, isClosed: Bool) {
        self.id = challengeItem.id
        self.title = challengeItem.title
        self.thumbnailImageUrl = challengeItem.imageUrl ?? ""
        
        let progress = challengeItem.progress ?? 0.0
        self.progressText = String(format: "%.0f%%", progress * 100)
        
        self.author = ""
        self.isRecruitmentClosed = isClosed
        
        self.createdAt = Date()
        self.startDate = Date()
    }
}
