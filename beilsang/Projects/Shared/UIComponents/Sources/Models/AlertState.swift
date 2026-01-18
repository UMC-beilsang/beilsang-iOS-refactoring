//
//  AlertState.swift
//  AuthFeature
//
//  Created by Seyoung Park on 8/29/25.
//

import Foundation

public struct AlertState: Identifiable {
    public let id = UUID()  
    public let title: String
    public let message: String
    
    public init(title: String, message: String) {
        self.title = title
        self.message = message
    }
}
