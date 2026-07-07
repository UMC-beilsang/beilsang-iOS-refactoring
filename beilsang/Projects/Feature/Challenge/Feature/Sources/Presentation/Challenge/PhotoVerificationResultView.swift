//
//  PhotoVerificationResultView.swift
//  ChallengeFeature
//

import SwiftUI
import DesignSystemShared

// MARK: - Verification Result Sheet (제출 전 바텀시트)

public struct PhotoVerificationSheet: View {
    let result: PhotoVerificationResult?
    let failed: Bool
    let onConfirm: () -> Void    // 제출 확정
    let onRetry: () -> Void      // 다른 사진 선택

    public init(
        result: PhotoVerificationResult?,
        failed: Bool,
        onConfirm: @escaping () -> Void,
        onRetry: @escaping () -> Void
    ) {
        self.result = result
        self.failed = failed
        self.onConfirm = onConfirm
        self.onRetry = onRetry
    }

    public var body: some View {
        VStack(spacing: 0) {
            dragIndicator

            if let result {
                resultContent(result: result)
            } else if failed {
                failedContent
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
    }

    // MARK: - Result Content

    private func resultContent(result: PhotoVerificationResult) -> some View {
        VStack(spacing: 0) {
            Text("AI 인증 검사 결과")
                .fontStyle(.heading2Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)
                .padding(.top, 28)
                .padding(.bottom, 32)

            LargeCircularGauge(result: result)
                .padding(.bottom, 20)

            Text(result.feedback)
                .fontStyle(.body1Medium)
                .foregroundStyle(ColorSystem.labelNormalBasic)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
                .padding(.bottom, 36)

            actionButtons(result: result)
        }
    }

    // MARK: - Failed Content (검증 자체가 실패한 경우)

    private var failedContent: some View {
        VStack(spacing: 0) {
            Text("AI 인증 검사 결과")
                .fontStyle(.heading2Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)
                .padding(.top, 28)
                .padding(.bottom, 32)

            Image(systemName: "wifi.slash")
                .font(.system(size: 40))
                .foregroundStyle(ColorSystem.labelNormalBasic)
                .padding(.bottom, 16)

            Text("AI 검사에 실패했어요")
                .fontStyle(.body1SemiBold)
                .foregroundStyle(ColorSystem.labelNormalBasic)
                .padding(.bottom, 8)

            Text("그래도 인증을 제출하거나\n사진을 다시 선택할 수 있어요")
                .fontStyle(.detail1Regular)
                .foregroundStyle(ColorSystem.labelNormalBasic)
                .multilineTextAlignment(.center)
                .padding(.bottom, 36)

            VStack(spacing: 12) {
                primaryButton(title: "그래도 제출하기", action: onConfirm)
                secondaryButton(title: "다른 사진 선택", action: onRetry)
            }
        }
    }

    // MARK: - Action Buttons

    private func actionButtons(result: PhotoVerificationResult) -> some View {
        VStack(spacing: 12) {
            if result.isValid {
                primaryButton(title: "인증 제출하기", action: onConfirm)
                secondaryButton(title: "다른 사진 선택", action: onRetry)
            } else {
                primaryButton(title: "다른 사진 선택", action: onRetry)
                secondaryButton(title: "그래도 제출하기", action: onConfirm)
            }
        }
    }

    private func primaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .fontStyle(.heading2Bold)
                .foregroundStyle(ColorSystem.labelWhite)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(ColorSystem.primaryStrong)
                .cornerRadius(16)
        }
    }

    private func secondaryButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .fontStyle(.body1SemiBold)
                .foregroundStyle(ColorSystem.labelNormalBasic)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(ColorSystem.labelNormalDisable)
                .cornerRadius(16)
        }
    }

    private var dragIndicator: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(ColorSystem.labelNormalAlternative)
            .frame(width: 36, height: 5)
            .padding(.top, 12)
    }
}

// MARK: - Large Circular Gauge

private struct LargeCircularGauge: View {
    let result: PhotoVerificationResult
    @State private var animatedProgress: Double = 0

    private var gaugeColor: Color {
        if result.score >= 70 { return Color(red: 0.20, green: 0.72, blue: 0.44) }
        else if result.score >= 50 { return Color(red: 1.0, green: 0.60, blue: 0.10) }
        else { return Color(red: 0.90, green: 0.25, blue: 0.25) }
    }

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(lineWidth: 10)
                    .foregroundStyle(gaugeColor.opacity(0.15))

                Circle()
                    .trim(from: 0, to: animatedProgress)
                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .foregroundStyle(gaugeColor)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 4) {
                    Text("\(result.score)%")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(gaugeColor)
                    Text("일치도")
                        .fontStyle(.detail1Regular)
                        .foregroundStyle(ColorSystem.labelNormalBasic)
                }
            }
            .frame(width: 140, height: 140)

            statusBadge
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) {
                animatedProgress = Double(result.score) / 100.0
            }
        }
    }

    private var statusBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: result.statusIcon)
                .font(.system(size: 14, weight: .semibold))
            Text(result.statusText)
                .fontStyle(.body1SemiBold)
        }
        .foregroundStyle(gaugeColor)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(gaugeColor.opacity(0.1))
        .cornerRadius(20)
    }
}

// MARK: - Submit Button Loading Overlay

public struct VerifyingOverlayView: View {
    @State private var isSpinning = false

    public init() {}

    public var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 3)
                    .frame(width: 22, height: 22)
                Circle()
                    .trim(from: 0, to: 0.72)
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 22, height: 22)
                    .rotationEffect(.degrees(isSpinning ? 360 : 0))
                    .animation(.linear(duration: 0.8).repeatForever(autoreverses: false), value: isSpinning)
            }
            Text("AI 검사 중...")
                .fontStyle(.heading2Bold)
                .foregroundStyle(Color.white)
        }
        .onAppear { isSpinning = true }
    }
}
