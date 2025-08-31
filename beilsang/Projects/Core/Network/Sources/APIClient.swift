//
//  APIClient.swift
//  NetworkCore
//
//  Created by Seyoung Park on 8/31/25.
//

import Foundation

public final class APIClient {
    private let baseURL: String
    
    public init(baseURL: String) {
        self.baseURL = baseURL
    }
    
    public func get(path: String) async throws -> Data {
        guard let url = URL(string: baseURL + path) else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}
