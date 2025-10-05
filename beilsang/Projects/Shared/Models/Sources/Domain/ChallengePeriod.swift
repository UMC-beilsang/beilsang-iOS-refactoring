//
//  ChallengePeriod.swift
//  ModelsShared
//
//  Created by Seyoung Park on 10/3/25.
//

import Foundation

public enum ChallengePeriod: String, CaseIterable, Hashable, Identifiable {
    case week
    case month

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .week: return "일주일"
        case .month: return "한달"
        }
    }

    public func maxCount(startDate: Date? = nil) -> Int {
        let calendar = Calendar.current
        switch self {
        case .week:
            return 7
        case .month:
            guard let startDate = startDate else {
                // 시작일 없으면 기본 30일
                return 30
            }
            // 시작일 + 1개월
            guard let endDate = calendar.date(byAdding: .month, value: 1, to: startDate) else {
                return 30
            }
            // 시작일부터 endDate 전날까지의 일수
            let days = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 30
            return days
        }
    }

    public static var dropdownOptions: [ChallengePeriod] {
        return Self.allCases
    }
}
