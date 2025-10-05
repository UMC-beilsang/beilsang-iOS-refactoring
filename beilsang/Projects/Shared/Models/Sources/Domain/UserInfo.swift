//
//  UserInfo.swift
//  ModelsShared
//
//  Created by Seyoung Park on 8/30/25.
//

import Foundation

public struct UserInfo {
    public var nickname: String
    public var birthDate: Date?
    public var gender: String? = nil
    public var address: String
    public var addressDetail: String
    
    public init(
        nickname: String = "",
        birthDate: Date? = nil,
        gender: String = "",
        address: String = "",
        addressDetail: String = ""
    ) {
        self.nickname = nickname
        self.birthDate = birthDate
        self.gender = gender
        self.address = address
        self.addressDetail = addressDetail
    }
    
    public var isFilled: Bool {
        !nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        birthDate != nil &&
        ((gender?.isEmpty) == nil) &&
        !address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

public enum UserInfoField: Hashable {
    case nickname
    case address
    case addressDetail
}

