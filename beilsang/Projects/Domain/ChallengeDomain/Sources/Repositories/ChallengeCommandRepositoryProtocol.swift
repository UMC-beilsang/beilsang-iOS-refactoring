//
//  ChallengeCommandRepositoryProtocol.swift
//  ChallengeDomain
//
//  Created by Seyoung Park on 12/26/25.
//

import Foundation
import ModelsShared

/// 챌린지 변경 작업 전용 Repository
public protocol ChallengeCommandRepositoryProtocol {
    func participateInChallenge(challengeId: Int) async throws
    func reportChallenge(challengeId: Int) async throws
    func createChallenge(request: ChallengeCreateRequest, infoImages: [Data], certImages: [Data]) async throws -> ChallengeCreateResponse
}

