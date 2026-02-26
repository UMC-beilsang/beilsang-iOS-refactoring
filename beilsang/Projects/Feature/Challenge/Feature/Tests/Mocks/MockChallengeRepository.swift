//
//  MockChallengeRepository.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/1/25.
//

import Foundation
@testable import ChallengeFeature
import ChallengeDomain
import ModelsShared  // 추가

public final class MockChallengeRepository: ChallengeRepositoryProtocol {
    var shouldSucceed = true
    var mockChallenges: [Challenge] = []  
    
    public func fetchActiveChallenges() async throws -> [Challenge] {
        if shouldSucceed {
            return mockChallenges
        } else {
            throw MockError.networkError
        }
    }
    
    public func fetchRecommendedChallenges() async throws -> [Challenge] {
        if shouldSucceed {
            return mockChallenges
        } else {
            throw MockError.networkError
        }
    }
    
    public func participateInChallenge(challengeId: String) async throws {
        if !shouldSucceed {
            throw MockError.participationFailed
        }
    }
    
    public func reportChallenge(challengeId: String) async throws {
        if !shouldSucceed {
            throw MockError.reportFailed
        }
    }
}

public enum MockError: Error {
    case networkError
    case participationFailed
    case reportFailed
}
