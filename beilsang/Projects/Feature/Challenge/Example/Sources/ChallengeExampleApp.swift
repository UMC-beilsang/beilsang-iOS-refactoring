//
//  ChallengeExampleApp.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/1/25.
//

import SwiftUI
import DesignSystemShared
import UIComponentsShared
import ModelsShared
@testable import ChallengeFeature
import ChallengeDomain

@main
struct ChallengeExampleApp: App {
    @StateObject private var toastManager = ToastManager()
    
    init() {
        FontRegister.registerFonts()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(toastManager)
        }
    }
}

struct ContentView: View {
    var body: some View {
        ChallengeDetailView(
            viewModel: ChallengeDetailViewModel(
                challenge: mockChallenge,
                repository: MockChallengeRepository()
            )
        )
        .withToastLow()
    }
    
    // 테스트용 Mock 챌린지 데이터 - 상태별로 테스트해보세요!
    private var mockChallenge: Challenge {
        Challenge(
            id: "1",
            title: "플로깅 챌린지",
            description: """
            일주일에 한 번씩 길을 걸으며 플로깅을 해보는 건 어떨까요?
            '우리 가치 플로깅하자'는 챌린저 분들이 함께 활동을 인증하며 플로깅 문화를 확장시키는 챌린지입니다! 여러분의 많은 참여 기대하겠습니다!
            """,
            category: "plogging",
            status: "RECRUITING",        // "RECRUITING", "IN_PROGRESS", "CALCULATING", "ENDED_SUCCESS"
            progress: 65.0,
            startDate: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 25, to: Date()) ?? Date(),
            currentParticipants: 47,
            maxParticipants: 100,
            depositAmount: 1000,
            certificationMethod: "사진 인증",
            infoImageUrls: ["challengeThumbnail1"],
            certImageUrls: ["challengeThumbnail1", "challengeThumbnail2"],
            thumbnailImageUrl: "challengeThumbnail1",
            isLiked: false,
            likeCount: 23,
            isParticipating: false,
            createdAt: Date()
        )
    }
}
