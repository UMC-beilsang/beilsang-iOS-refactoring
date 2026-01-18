//
//  APIResponse.swift
//  ModelsShared
//
//  Created by Seyoung Park on 11/26/25.
//

import Foundation

public struct APIResponse<DataType: Decodable>: Decodable, Sendable {
    public let statusCode: Int
    public let code: String
    public let message: String
    public let data: DataType?

    public var isSuccess: Bool {
        statusCode == 200
    }
}

