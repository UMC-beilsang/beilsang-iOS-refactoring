//
//  PointModels.swift
//  ModelsShared
//
//  Created by Seyoung Park on 11/30/25.
//

import Foundation

// MARK: - API Response Models (GET /api/point)
public struct PointAPIResponseData: Codable, Sendable {
    public let total: Int
    public let points: [PointItem]
    
    public init(total: Int, points: [PointItem]) {
        self.total = total
        self.points = points
    }
}

// MARK: - Domain Models
public struct PointData: Codable, Sendable {
    public let total: Int
    public let point: [PointItem]
    
    public init(total: Int, point: [PointItem]) {
        self.total = total
        self.point = point
    }
}

public struct PointItem: Codable, Identifiable, Sendable {
    public let id: Int
    public let name: String?
    public let status: PointStatus
    public let value: Int
    public let date: String
    public let period: Int?
    
    public init(id: Int, name: String?, status: PointStatus, value: Int, date: String, period: Int?) {
        self.id = id
        self.name = name
        self.status = status
        self.value = value
        self.date = date
        self.period = period
    }
}

public enum PointStatus: String, Codable, Sendable {
    case earn = "EARN"
    case use = "USE"
    case expire = "EXPIRE"
    
    public var displayName: String {
        switch self {
        case .earn: return "적립"
        case .use: return "사용"
        case .expire: return "소멸"
        }
    }
}




