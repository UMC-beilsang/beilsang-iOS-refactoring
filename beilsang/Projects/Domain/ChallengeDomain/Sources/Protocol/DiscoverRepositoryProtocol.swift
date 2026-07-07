//
//  DiscoverRepositoryProtocol.swift
//  ChallengeDomain
//
//  Created by Seyoung Park on 3/10/26.
//

import Foundation
import ModelsShared

// 발견
public protocol DiscoverRepositoryProtocol {
    func fetchKeywordFeeds(by keyword: Keyword, page: Int, size: Int) async throws -> DiscoverFeedPageData
    func fetchHonorsChallenges(by keyword: Keyword) async throws -> HallOfFameData
}
