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
    
    public init(challenge: Challenge) {
        self.id = challenge.id
        self.title = challenge.title
        self.thumbnailImageUrl = challenge.thumbnailImageUrl ?? ""
        self.progressText = String(format: "%.0f%%", challenge.progress)
        self.author = challenge.author
        self.isRecruitmentClosed = challenge.isRecruitmentClosed
        self.createdAt = challenge.createdAt
        self.startDate = challenge.startDate
    }
}
