//
//  PhotoVerificationUIGalleryView.swift
//  ChallengeFeatureExample
//

import SwiftUI
import ChallengeFeature
import DesignSystemShared

/// 앱과 동일한 PhotoVerificationSheet / VerifyingOverlayView 컴포넌트 미리보기
struct PhotoVerificationUIGalleryView: View {
    @State private var activeScenario: VerificationPreviewScenario?
    @State private var showVerifyingDemo = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                resultSheetSection
                verifyingOverlaySection
            }
            .padding(24)
        }
        .navigationTitle("UI 미리보기")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $activeScenario) { scenario in
            PhotoVerificationSheet(
                result: scenario.result,
                failed: scenario.failed,
                onConfirm: { activeScenario = nil },
                onRetry: { activeScenario = nil }
            )
            .presentationDetents([.height(480)])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Result Sheet Presets

    private var resultSheetSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI 인증 검사 결과 시트")
                .fontStyle(.heading3Bold)

            Text("앱 인증하기 → 제출 시 뜨는 바텀시트와 동일합니다.")
                .fontStyle(.detail1Medium)
                .foregroundStyle(ColorSystem.labelNormalBasic)

            VStack(spacing: 10) {
                ForEach(VerificationPreviewScenario.allCases) { scenario in
                    Button {
                        activeScenario = scenario
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(scenario.title)
                                    .fontStyle(.body1SemiBold)
                                    .foregroundStyle(ColorSystem.labelNormalStrong)
                                Text(scenario.subtitle)
                                    .fontStyle(.detail1Medium)
                                    .foregroundStyle(ColorSystem.labelNormalBasic)
                            }
                            Spacer()
                            scenarioBadge(scenario)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(ColorSystem.labelNormalAlternative)
                        }
                        .padding(16)
                        .background(ColorSystem.labelNormalDisable)
                        .cornerRadius(12)
                    }
                }
            }
        }
    }

    private func scenarioBadge(_ scenario: VerificationPreviewScenario) -> some View {
        Text(scenario.badgeText)
            .fontStyle(.detail1Medium)
            .foregroundStyle(scenario.badgeColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(scenario.badgeColor.opacity(0.12))
            .cornerRadius(999)
    }

    // MARK: - Verifying Overlay

    private var verifyingOverlaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("제출 버튼 · AI 검사 중")
                .fontStyle(.heading3Bold)

            Text("인증하기 화면 하단 버튼에 표시되는 로딩 UI입니다.")
                .fontStyle(.detail1Medium)
                .foregroundStyle(ColorSystem.labelNormalBasic)

            Button {
                showVerifyingDemo.toggle()
                if showVerifyingDemo {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        showVerifyingDemo = false
                    }
                }
            } label: {
                Group {
                    if showVerifyingDemo {
                        VerifyingOverlayView()
                    } else {
                        Text("챌린지 인증하기")
                            .fontStyle(.heading2Bold)
                            .foregroundStyle(ColorSystem.labelWhite)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(ColorSystem.primaryStrong)
                .cornerRadius(20)
            }
        }
    }
}

// MARK: - Preview Scenarios

private enum VerificationPreviewScenario: String, CaseIterable, Identifiable {
    case passHigh
    case passBorder
    case failMid
    case failLow
    case networkError

    var id: String { rawValue }

    var title: String {
        switch self {
        case .passHigh: return "95점 · 인증 적합"
        case .passBorder: return "70점 · 경계 통과"
        case .failMid: return "55점 · 재검토 필요"
        case .failLow: return "30점 · 재검토 필요"
        case .networkError: return "API 실패"
        }
    }

    var subtitle: String {
        switch self {
        case .passHigh: return "초록 게이지 · 인증 제출하기 (메인)"
        case .passBorder: return "70점 이상 최소 통과 · 인증 제출하기"
        case .failMid: return "주황 게이지 · 다른 사진 선택 (메인)"
        case .failLow: return "빨강 게이지 · 그래도 제출하기 (서브)"
        case .networkError: return "wifi.slash · 그래도 제출하기"
        }
    }

    var badgeText: String {
        switch self {
        case .passHigh, .passBorder: return "통과"
        case .failMid, .failLow: return "재검토"
        case .networkError: return "오류"
        }
    }

    var badgeColor: Color {
        switch self {
        case .passHigh, .passBorder:
            return Color(red: 0.20, green: 0.72, blue: 0.44)
        case .failMid:
            return Color(red: 1.0, green: 0.60, blue: 0.10)
        case .failLow, .networkError:
            return Color(red: 0.90, green: 0.25, blue: 0.25)
        }
    }

    var result: PhotoVerificationResult? {
        switch self {
        case .passHigh:
            return PhotoVerificationResult(
                score: 95,
                isValid: true,
                feedback: "실외 걷기 사진으로 챌린지 인증에 적합합니다."
            )
        case .passBorder:
            return PhotoVerificationResult(
                score: 70,
                isValid: true,
                feedback: "챌린지 주제와 관련된 사진입니다."
            )
        case .failMid:
            return PhotoVerificationResult(
                score: 55,
                isValid: false,
                feedback: "챌린지와 다소 관련이 적어 보입니다."
            )
        case .failLow:
            return PhotoVerificationResult(
                score: 30,
                isValid: false,
                feedback: "챌린지와 관련 없는 사진입니다."
            )
        case .networkError:
            return nil
        }
    }

    var failed: Bool {
        self == .networkError
    }
}
