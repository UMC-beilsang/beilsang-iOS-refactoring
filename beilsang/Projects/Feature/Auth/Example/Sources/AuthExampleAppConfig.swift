//
//  AuthExampleAppConfig.swift
//  AuthFeature
//
//  Created by Seyoung Park on 8/31/25.
//

import Foundation

enum AuthExampleAppConfig {
    private static func value(for key: String) -> String {
        Bundle.main.object(forInfoDictionaryKey: key) as? String ?? ""
    }

    static var baseURL: String {
        "https://" + value(for: "BASE_URL")
    }

    static let kakaoAppKey = value(for: "KAKAO_APP_KEY")
}
