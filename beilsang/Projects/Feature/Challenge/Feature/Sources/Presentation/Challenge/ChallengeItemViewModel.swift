//
//  ChallengeItemViewModel.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/3/25.
//

import Foundation
import ChallengeDomain

struct ChallengeItemViewModel: Identifiable {
    let id: String
    let title: String
    let thumbnailImageUrl: String
    
    // 카드에서 보여줄 값들
    let progressText: String        // "45%" 형식 (달성률)
    let participantsText: String    // "23/50명" (참여 인원)
    
    let author: String
    
    init(challenge: Challenge, author: String? = nil) {
        self.id = challenge.id
        self.title = challenge.title
        self.thumbnailImageUrl = challenge.thumbnailImageUrl ?? "" 
        self.progressText = String(format: "%.0f%%", challenge.progress)
        self.participantsText = "\(challenge.currentParticipants)명"
        self.author = challenge.author
    }
}
