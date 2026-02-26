//
//  ChallengeFilter.swift
//  ModelsShared
//
//  Created by Seyoung
//

import Foundation

public enum ChallengeFilter: String, CaseIterable {
    case recent = "기본순"
    case latest = "최신순"
    
    public var description: String {
        switch self {
        case .recent:
            return "시작일이 가까운 챌린지부터 보여요"
        case .latest:
            return "새로 등록된 챌린지부터 보여요"
        }
    }
}
