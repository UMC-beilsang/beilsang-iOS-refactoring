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

    public static let baseURL: String = {
        var url = value(for: "BASE_URL").trimmingCharacters(in: .whitespacesAndNewlines)

        guard !url.isEmpty else { return "" }

        if !url.hasPrefix("http://") && !url.hasPrefix("https://") {
            url = "https://" + url
        }

        if url.hasSuffix("/") {
            url.removeLast()
        }

        return url
    }()

    public static let kakaoAppKey: String = value(for: "KAKAO_APP_KEY")
}
