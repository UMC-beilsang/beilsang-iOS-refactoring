//
//  PhotoVerificationExampleRootView.swift
//  ChallengeFeatureExample
//

import SwiftUI
import ChallengeFeature
import DesignSystemShared
import UIComponentsShared

struct PhotoVerificationExampleRootView: View {
    @StateObject private var toastManager = ToastManager()

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        PhotoVerificationUIGalleryView()
                    } label: {
                        Label("결과 시트 UI 미리보기", systemImage: "rectangle.on.rectangle.angled")
                    }

                    NavigationLink {
                        PhotoVerificationDebugView()
                    } label: {
                        Label("실제 AI 검사", systemImage: "sparkles")
                    }

                    NavigationLink {
                        ChallengeCertPreviewView()
                            .environmentObject(toastManager)
                    } label: {
                        Label("인증 화면 전체", systemImage: "camera.fill")
                    }
                } header: {
                    Text("AI 인증 테스트")
                } footer: {
                    Text("UI 미리보기는 앱과 동일한 PhotoVerificationSheet를 점수별로 확인합니다.")
                }
            }
            .navigationTitle("Challenge Example")
        }
    }
}

// MARK: - Full Cert Screen Preview

private struct ChallengeCertPreviewView: View {
    private let container = ChallengeContainer()
    private let sampleContext = ChallengeVerificationContext(
        title: "매일 30분 걷기",
        description: "하루 30분 이상 걷는 모습을 인증해 주세요.",
        category: "운동",
        notes: [
            "실외/실내에서 걷거나 조깅하는 모습",
            "운동 앱 캡처도 가능"
        ]
    )

    var body: some View {
        ChallengeCertView(
            viewModel: container.makeChallengeCertViewModel(
                challengeId: 0,
                challengeContext: sampleContext
            )
        )
    }
}
