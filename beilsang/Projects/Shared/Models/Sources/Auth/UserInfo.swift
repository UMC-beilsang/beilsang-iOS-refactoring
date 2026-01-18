//
//  UserInfo.swift
//  ModelsShared
//
//  Created by Seyoung Park on 8/30/25.
//

import Foundation

/// A shared model representing the basic information of a user.
///
/// - Used across multiple features such as Sign-Up, My Page, and Profile Editing.
/// - Serves as a reusable **value object**, not tied to any specific domain logic.
public struct UserInfo: Equatable {
    public var nickname: String
    public var birthDate: Date?
    public var gender: String? = nil
    public var address: String
    public var addressDetail: String
    
    public init(
        nickname: String = "",
        birthDate: Date? = nil,
        gender: String? = nil,
        address: String = "",
        addressDetail: String = ""
    ) {
        self.nickname = nickname
        self.birthDate = birthDate
        self.gender = gender
        self.address = address
        self.addressDetail = addressDetail
    }
    
    /// Checks if all required fields are filled.
    public var isFilled: Bool {
        !nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        birthDate != nil &&
        gender != nil && !gender!.isEmpty &&
        !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

/// Represents the editable fields in the `UserInfo` form.
///
/// Used to manage focus states and identify specific input fields in the UI.
public enum UserInfoField: Hashable {
    case nickname
    case address
    case addressDetail
}
