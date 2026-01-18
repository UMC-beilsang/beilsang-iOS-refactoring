//
//  SignUpData.swift
//  AuthDomain
//
//  Created by Seyoung Park on 8/31/25.
//

import Foundation
import ModelsShared
import UtilityShared

/// Domain model for managing UI input values in the sign-up flow,
/// used until conversion to `SignUpRequest` for server transmission
///
/// - ViewModel binds user input values to populate this object
/// - Sign-up UseCase converts this model to `SignUpRequest` for server communication
public struct SignUpData: Equatable {
    public var accessToken: String = ""
    public var keyword: Keyword? = nil
    public var motto: Motto? = nil
    public var userInfo: UserInfo = .init()
    public var referralInfo: ReferralInfo = .init()

    public init() {}

    public func toRequest() -> SignUpRequest {
        SignUpRequest(
            accessToken: accessToken,
            gender: userInfo.gender ?? "기타",
            nickName: userInfo.nickname,
            birth: userInfo.birthDate?.toServerFormat() ?? "",
            address: userInfo.address,
            keyword: keyword?.rawValue ?? "",
            discoveredPath: referralInfo.source ?? "",
            resolution: motto?.rawValue ?? "",
            recommendNickname: referralInfo.recommender
        )
    }
}
