//
//  AppConfig.swift
//  App
//
//  Created by Seyoung Park on 8/31/25.
//

import Foundation

public enum AppConfig {
    private static func value(for key: String) -> String {
        Bundle.main.object(forInfoDictionaryKey: key) as? String ?? ""
    }

    public static let baseURL: String = value(for: "BASE_URL")
    public static let kakaoAppKey: String = value(for: "KAKAO_APP_KEY")
}
