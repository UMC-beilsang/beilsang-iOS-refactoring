//
//  DotsLoadingView.swift
//  UIComponentsShared
//

import SwiftUI
import DesignSystemShared

/// 앱 공통 로딩 인디케이터.
/// - `.inline`: 페이지네이션, 초기 로딩 등 인라인 배치용 (작은 점 3개)
/// - `.overlay(message:)`: 전체화면 블로킹 오버레이용 (다크 카드 + 텍스트)
public struct DotsLoadingView: View {
    public enum Style {
        case inline
        case overlay(message: String = "로딩 중...")
    }

    private let style: Style
    @State private var animating = false

    public init(style: Style = .inline) {
        self.style = style
    }

    public var body: some View {
        switch style {
        case .inline:
            dots(size: 8, spacing: 6, color: ColorSystem.primaryStrong)
                .onAppear {
                    DispatchQueue.main.async { animating = true }
                }
                .onDisappear { animating = false }

        case .overlay(let message):
            VStack(spacing: 20) {
                dots(size: 12, spacing: 10, color: ColorSystem.primaryStrong)
                Text(message)
                    .fontStyle(.body2SemiBold)
                    .foregroundStyle(ColorSystem.labelWhite)
            }
            .padding(.horizontal, 36)
            .padding(.vertical, 28)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.6))
            )
            .onAppear {
                DispatchQueue.main.async { animating = true }
            }
            .onDisappear { animating = false }
        }
    }

    private func dots(size: CGFloat, spacing: CGFloat, color: Color) -> some View {
        HStack(spacing: spacing) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(color)
                    .frame(width: size, height: size)
                    .scaleEffect(animating ? 1.4 : 0.7)
                    .opacity(animating ? 1.0 : 0.4)
                    .animation(
                        .easeInOut(duration: 0.5)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.18),
                        value: animating
                    )
            }
        }
    }
}
