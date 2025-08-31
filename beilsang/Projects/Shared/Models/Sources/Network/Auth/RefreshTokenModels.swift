//
//  RefreshTokenModels.swift
//  ModelsShared
//
//  Created by Seyoung Park on 8/31/25.
//

import Foundation

public struct RefreshTokenRequest: Codable, Sendable {
    let refreshToken: String
    
    public init(from token: String) {
        self.refreshToken = token
    }
}
