//
//  DateFormatter.swift
//  UtilityShared
//
//  Created by Seyoung Park on 9/9/25.
//

import Foundation

extension DateFormatter {
    public static let koreanDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy년 MM월 dd일"
        return formatter
    }()
    
    public static let koreanDateWithWeekday: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy년 MM월 dd일 (EE)"
        return formatter
    }()
}
