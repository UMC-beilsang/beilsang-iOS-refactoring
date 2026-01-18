//
//  MockConfig.swift
//  UtilityShared
//
//  Created by Seyoung Park on 11/26/25.
//

import Foundation

/// Mock 데이터 사용 여부를 제어하는 전역 설정
public struct MockConfig {
    /// Mock 데이터 사용 여부 (true: Mock 사용, false: 실제 API 사용)
    ///
    /// - 현재 설정: DEBUG 빌드에서는 항상 Mock 사용, RELEASE에서는 실제 API 사용
    /// - 스킴/번들 ID와 상관없이 개발 중에는 무조건 목업을 보기 위해 단순화
    public static var useMockData: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    private init() {}
}


