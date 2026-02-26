//
//  ImageUploadModels.swift
//  ModelsShared
//
//  Created by Seyoung Park on 11/27/25.
//

import Foundation

// MARK: - Response
public typealias ImageUploadResponse = APIResponse<ImageUploadData>

public struct ImageUploadData: Codable, Sendable {
    public let imageUrl: String
    
    public init(imageUrl: String) {
        self.imageUrl = imageUrl
    }
}





