//
//  ChallengeEnrollmentModels.swift
//  ModelsShared
//
//  Created by Seyoung Park on 11/26/25.
//

import Foundation

// MARK: - Response
public typealias ChallengeEnrollmentResponse = APIResponse<ChallengeEnrollmentData>

public struct ChallengeEnrollmentData: Codable, Sendable {
    public let isEnrolled: Bool
    public let enrolledChallengeIds: [Int]
    
    public init(isEnrolled: Bool, enrolledChallengeIds: [Int]) {
        self.isEnrolled = isEnrolled
        self.enrolledChallengeIds = enrolledChallengeIds
    }
}

