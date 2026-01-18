//
//  PointModels.swift
//  ModelsShared
//
//  Created by Seyoung Park on 11/30/25.
//

import Foundation

// MARK: - Response
public struct PointResponse: Codable, Sendable {
    public let statusCode: Int
    public let code: String
    public let message: String
    public let data: PointData
    
    public init(statusCode: Int, code: String, message: String, data: PointData) {
        self.statusCode = statusCode
        self.code = code
        self.message = message
        self.data = data
    }
}

public struct PointData: Codable, Sendable {
    public let total: Int
    public let points: [PointItem]
    
    public init(total: Int, points: [PointItem]) {
        self.total = total
        self.points = points
    }
}

// MARK: - Point Item
public struct PointItem: Codable, Identifiable, Sendable {
    public let id: Int
    public let name: String
    public let status: PointStatus
    public let value: Int
    public let date: String
    public let period: Int
    
    public init(id: Int, name: String, status: PointStatus, value: Int, date: String, period: Int) {
        self.id = id
        self.name = name
        self.status = status
        self.value = value
        self.date = date
        self.period = period
    }
}

// MARK: - Point Status
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



