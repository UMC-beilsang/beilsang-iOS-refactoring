//
//  ValidationResult.swift
//  AuthDomain
//
//  Created by Seyoung Park on 9/1/25.
//

import Foundation

public struct ValidationResult {
    public let isValid: Bool
    public let errors: [ValidationError]
}
