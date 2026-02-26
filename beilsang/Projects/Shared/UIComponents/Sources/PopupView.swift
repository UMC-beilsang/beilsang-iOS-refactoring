//
//  PopupView.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 9/10/25.
//

import SwiftUI
import DesignSystemShared

public struct PopupView: View {
    // Style은 세 가지
    public enum Style {
        case alert(message: String, subMessage: String?)
        case alertCountdown(message: String, seconds: Int)
        case content(type: ContentType)

        public enum ContentType {
            case point(minRequiredPoint: Int, earnedPoint: Int)
            case cert(minRequiredPoint: Int, numberOfCert: Int, certUnit: String)
        }
    }

    let title: String
    let style: Style
    let primary: PopupAction?
    let secondary: PopupAction?

    public init(
        title: String,
        style: Style,
        primary: PopupAction? = nil,
        secondary: PopupAction? = nil
    ) {
        self.title = title
        self.style = style
        self.primary = primary
        self.secondary = secondary
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 0) {
            // Section 1. Title (공통)
            Text(title)
                .fontStyle(.heading1Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)
                .padding(.top, 28)
                .padding(.bottom, 16)

            // Section 2. Content (스타일별)
            switch style {
            case let .alert(message, subMessage):
                VStack(spacing: 10) {
                    Text(message)
                        .fontStyle(.body2SemiBold)
                        .foregroundStyle(ColorSystem.labelNormalNormal)
                        .multilineTextAlignment(.center)

                    if let subMessage = subMessage {
                        Text(subMessage)
                            .fontStyle(.detail1Medium)
                            .foregroundStyle(ColorSystem.labelNormalBasic)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.top, 12)
                .padding(.bottom, 24)

            case let .alertCountdown(message, seconds):
                VStack(spacing: 10) {
                    Text(message)
                        .fontStyle(.body2SemiBold)
                        .foregroundStyle(ColorSystem.labelNormalNormal)
                        .multilineTextAlignment(.center)

                    CountdownText(seconds: seconds)
                        .padding(.horizontal, 16)
                }
                .padding(.horizontal, 10)
                .padding(.top, 12)
                .padding(.bottom, 24)

            case let .content(type):
                switch type {
                case let .point(minRequiredPoint, earnedPoint):
                    VStack(spacing: 16) {
                        VStack(spacing: 2) {
                            Text("챌린지 참여 최소 포인트")
                                .fontStyle(.body2Medium)
                                .foregroundStyle(ColorSystem.labelNormalNormal)
                            
                            Text("\(minRequiredPoint)P")
                                .fontStyle(.body1Bold)
                                .foregroundStyle(ColorSystem.primaryStrong)
                        }
                        
                        Rectangle()
                            .fill(ColorSystem.lineNormal)
                            .frame(height: 1)
                            .padding(.horizontal, 16)
                        
                        VStack(spacing: 2) {
                            Text("현재 보유 포인트")
                                .fontStyle(.body2Medium)
                                .foregroundStyle(ColorSystem.labelNormalNormal)
                            
                            Text("\(earnedPoint)P")
                                .fontStyle(.body1Bold)
                                .foregroundStyle(ColorSystem.semanticNegativeHeavy)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(ColorSystem.labelNormalDisable)
                            .padding(.horizontal, 16)
                    )
                    
                    VStack(spacing: 4) {
                        HStack(spacing: 0) {
                            Text("챌린지 참여 포인트보다  ")
                                .fontStyle(.body2SemiBold)
                            
                                .foregroundStyle(ColorSystem.labelNormalNormal)
                            Text("\(minRequiredPoint - earnedPoint)P")
                                .fontStyle(.body2SemiBold)
                                .foregroundStyle(ColorSystem.semanticNegativeHeavy)
                            Text(" 부족해요")
                                .fontStyle(.body2SemiBold)
                                .foregroundStyle(ColorSystem.labelNormalNormal)
                        }
                        
                        Text("포인트를 충전할까요?")
                            .fontStyle(.body2SemiBold)
                            .foregroundStyle(ColorSystem.labelNormalNormal)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                    .padding(.horizontal, 10)
                    
                case let .cert(minRequiredPoint, numberOfCert, certUnit):
                    VStack(spacing: 16) {
                        VStack(spacing: 2) {
                            Text("챌린지 참여 최소 포인트")
                                .fontStyle(.body2Medium)
                                .foregroundStyle(ColorSystem.labelNormalNormal)
                            
                            Text("\(minRequiredPoint)P")
                                .fontStyle(.body1Bold)
                                .foregroundStyle(ColorSystem.primaryStrong)
                        }
                        
                        Rectangle()
                            .fill(ColorSystem.lineNormal)
                            .frame(height: 1)
                            .padding(.horizontal, 16)
                        
                        VStack(spacing: 2) {
                            Text("챌린지 실천 기간")
                                .fontStyle(.body2Medium)
                                .foregroundStyle(ColorSystem.labelNormalNormal)
                            
                            HStack(spacing: 0) {
                                Text("시작일로부터 ")
                                    .fontStyle(.body2SemiBold)
                                    .foregroundStyle(ColorSystem.labelNormalStrong)
                                Text("\(certUnit) 동안 \(numberOfCert)회 ")
                                    .fontStyle(.body2SemiBold)
                                    .foregroundStyle(ColorSystem.primaryStrong)
                                Text("진행")
                                    .fontStyle(.body2SemiBold)
                                    .foregroundStyle(ColorSystem.labelNormalStrong)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(ColorSystem.labelNormalDisable)
                            .padding(.horizontal, 16)
                    )
                    
                    Text("해당 챌린지를 참여할까요?")
                        .fontStyle(.body2SemiBold)
                        .foregroundStyle(ColorSystem.labelNormalNormal)
                        .padding(.top, 12)
                        .padding(.bottom, 24)
                        .padding(.horizontal, 10)
                }
            }
            
            // Section 3. Action Button (공통)
            ButtonRow(primary: primary, secondary: secondary)
                .padding(.vertical, 12)
                .padding(.horizontal, 12)
        }
        .frame(width: UIScreen.main.bounds.width * 0.82)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(ColorSystem.backgroundNormalNormal)
                .shadow(color: ColorSystem.decorateShadowNormal, radius: 7, y: 7)
        )
    }
}

// MARK: - Buttons
private struct ButtonRow: View {
    let primary: PopupAction?
    let secondary: PopupAction?

    var body: some View {
        HStack(spacing: 12) {
            if let secondary = secondary {
                Button(action: secondary.handler) {
                    Text(secondary.title)
                        .fontStyle(.heading3Bold)
                        .foregroundStyle(ColorSystem.labelNormalBasic)
                        .frame(maxWidth: .infinity)
                }
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(ColorSystem.labelNormalAlternative)
                        .frame(height: 60)
                )
            }

            if let primary = primary {
                Button(action: primary.handler) {
                    Text(primary.title)
                        .fontStyle(.heading3Bold)
                        .foregroundStyle(ColorSystem.labelWhite)
                        .frame(maxWidth: .infinity)
                }
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(ColorSystem.primaryStrong)
                        .frame(height: 60)
                )
            }
        }
        .frame(height: 60)
    }
}

public struct PopupAction {
    public let title: String
    public let handler: () -> Void

    public init(title: String, handler: @escaping () -> Void) {
        self.title = title
        self.handler = handler
    }
}

// MARK: - CountdownText
private struct CountdownText: View {
    @State private var remaining: Int
    @State private var timer: Timer?

    init(seconds: Int) {
        _remaining = State(initialValue: seconds)
    }

    var body: some View {
        HStack(spacing: 0) {
            Text(formatTime(remaining))
                .fontStyle(.detail1Medium)
                .foregroundStyle(ColorSystem.primaryStrong)
            Text(" 후 정산 완료")
                .fontStyle(.detail1Medium)
                .foregroundStyle(ColorSystem.labelNormalBasic)
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remaining > 0 {
                remaining -= 1
            } else {
                stopTimer()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func formatTime(_ seconds: Int) -> String {
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        return "\(m)분 \(s)초"
    }
}
