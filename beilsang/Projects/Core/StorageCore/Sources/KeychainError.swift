//
//  KeychainError.swift
//  CoreStorage
//
//  Created by Seyoung Park on 8/31/25.
//

import Foundation

public enum KeychainError: Error, Equatable {
    case encodingFailed(String)
    case decodingFailed(String)
    case keychainSaveFailed(OSStatus)
    case keychainLoadFailed(OSStatus)
    case keychainDeleteFailed(OSStatus)
}
