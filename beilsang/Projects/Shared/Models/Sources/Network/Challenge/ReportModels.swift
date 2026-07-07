//
//  ReportModels.swift
//  ModelsShared
//

import Foundation

// MARK: - Feed Report
public struct FeedReportRequest: Encodable, Sendable {
    public let reason: String
    public let detail: String?

    public init(reason: String, detail: String? = nil) {
        self.reason = reason
        self.detail = detail
    }
}

// MARK: - Challenge Report
public struct ChallengeReportRequest: Encodable, Sendable {
    public let reason: String
    public let detail: String?

    public init(reason: String, detail: String? = nil) {
        self.reason = reason
        self.detail = detail
    }
}

public typealias FeedReportResponse = APIResponse<String>
public typealias ChallengeReportResponse = APIResponse<String>
