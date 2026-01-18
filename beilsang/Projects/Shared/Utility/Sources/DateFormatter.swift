//
//  DateFormatter.swift
//  UtilityShared
//
//  Created by Seyoung Park on 10/7/25.
//

import Foundation

public extension DateFormatter {
    /// Server format: yyyy-MM-dd
    static let serverFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    /// Front display format: yyyy년 MM월 dd일
    static let frontFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        return formatter
    }()
    
    /// Detail format: MM. dd
    static let detailFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM. dd"
        return formatter
    }()
    
    /// Join format: MM/dd
    static let joinFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter
    }()
    
    /// ISO format: yyyy-MM-dd'T'HH:mm:ss
    static let isoFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }()
}

public extension Date {
    /// Convert to server format string (yyyy-MM-dd)
    func toServerFormat() -> String {
        return DateFormatter.serverFormatter.string(from: self)
    }
    
    /// Convert to front display format (yyyy년 MM월 dd일)
    func toFrontFormat() -> String {
        return DateFormatter.frontFormatter.string(from: self)
    }
    
    /// Convert to detail format (MM. dd)
    func toDetailFormat() -> String {
        return DateFormatter.detailFormatter.string(from: self)
    }
    
    /// Convert to join format (MM/dd)
    func toJoinFormat() -> String {
        return DateFormatter.joinFormatter.string(from: self)
    }
    
    /// Get elapsed hours from now
    func elapsedHours() -> Int {
        let currentDate = Date()
        return Int(currentDate.timeIntervalSince(self) / 3600)
    }
}

public extension String {
    /// Parse server format date string (yyyy-MM-dd)
    func toDateFromServer() -> Date? {
        return DateFormatter.serverFormatter.date(from: self)
    }
    
    /// Parse ISO format date string (yyyy-MM-dd'T'HH:mm:ss)
    func toDateFromISO() -> Date? {
        return DateFormatter.isoFormatter.date(from: self)
    }
    
    /// Convert server date to front format
    func toFrontFormat() -> String? {
        guard let date = self.toDateFromServer() else { return nil }
        return date.toFrontFormat()
    }
    
    /// Convert server date to detail format
    func toDetailFormat() -> String? {
        guard let date = self.toDateFromServer() else { return nil }
        return date.toDetailFormat()
    }
    
    /// Convert server date to join format
    func toJoinFormat() -> String? {
        guard let date = self.toDateFromServer() else { return nil }
        return date.toJoinFormat()
    }
    
    /// Convert ISO date to elapsed hours string
    func toElapsedHours() -> String? {
        guard let date = self.toDateFromISO() else { return nil }
        return "\(date.elapsedHours())시간 전"
    }
}

// Day of week mapping
public enum DayOfWeek: String {
    case monday = "MONDAY"
    case tuesday = "TUESDAY"
    case wednesday = "WEDNESDAY"
    case thursday = "THURSDAY"
    case friday = "FRIDAY"
    case saturday = "SATURDAY"
    case sunday = "SUNDAY"
    
    public var koreanShort: String {
        switch self {
        case .monday: return "(월)"
        case .tuesday: return "(화)"
        case .wednesday: return "(수)"
        case .thursday: return "(목)"
        case .friday: return "(금)"
        case .saturday: return "(토)"
        case .sunday: return "(일)"
        }
    }
}
