//
//  ReportBottomSheet.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 6/21/26.
//

import SwiftUI
import DesignSystemShared
import UIComponentsShared

// MARK: - Protocol

public protocol ReportReasonProtocol: CaseIterable, Hashable {
    var title: String { get }
    var isOther: Bool { get }
    var apiKey: String { get }
}

// MARK: - Challenge Report Reason

public enum ChallengeReportReason: ReportReasonProtocol {
    case unrelatedToEcoChallenge
    case spamOrAdvertisement
    case inappropriateContent
    case dangerousOrIllegalActivity
    case other

    public var title: String {
        switch self {
        case .unrelatedToEcoChallenge:    return "친환경 챌린지 목적과 무관함"
        case .spamOrAdvertisement:        return "스팸 / 광고 / 홍보성 챌린지"
        case .inappropriateContent:       return "욕설·혐오·선정적 등 부적절한 내용 포함"
        case .dangerousOrIllegalActivity: return "위험하거나 불법적인 행위를 유도함"
        case .other:                      return "기타 (직접입력)"
        }
    }

    public var isOther: Bool { self == .other }

    public var apiKey: String {
        switch self {
        case .unrelatedToEcoChallenge:    return "UNRELATED"
        case .spamOrAdvertisement:        return "SPAM"
        case .inappropriateContent:       return "INAPPROPRIATE"
        case .dangerousOrIllegalActivity: return "ILLEGAL"
        case .other:                      return "ETC"
        }
    }
}

// MARK: - Feed Report Reason

public enum FeedReportReason: ReportReasonProtocol {
    case unrelatedToEcoChallenge
    case fakeOrManipulatedImage
    case spamOrAdvertisement
    case inappropriateContent
    case other

    public var title: String {
        switch self {
        case .unrelatedToEcoChallenge:  return "친환경 챌린지 목적과 무관함"
        case .fakeOrManipulatedImage:   return "허위 또는 조작(AI)된 이미지"
        case .spamOrAdvertisement:      return "스팸 / 광고 / 홍보성 게시물"
        case .inappropriateContent:     return "선정적·폭력적이거나 불쾌감을 주는 이미지"
        case .other:                    return "기타 (직접입력)"
        }
    }

    public var isOther: Bool { self == .other }

    public var apiKey: String {
        switch self {
        case .unrelatedToEcoChallenge:  return "UNRELATED"
        case .fakeOrManipulatedImage:   return "FALSE_CERT"
        case .spamOrAdvertisement:      return "SPAM"
        case .inappropriateContent:     return "INAPPROPRIATE"
        case .other:                    return "ETC"
        }
    }
}

// MARK: - Content Height Measurement

private struct SheetContentHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// MARK: - Generic Bottom Sheet

struct ReportBottomSheet<Reason: ReportReasonProtocol>: View
    where Reason.AllCases: RandomAccessCollection {

    let title: String
    let onCancel: () -> Void
    let onReasonSelected: (Reason, String?) -> Void
    @Binding var detent: PresentationDetent

    @State private var selectedReason: Reason? = nil
    @State private var otherText: String = ""
    @FocusState private var isTextFocused: Bool
    /// 실제 측정된 콘텐츠 높이 (기기 독립적)
    @State private var measuredHeight: CGFloat = 0

    private var isSubmitEnabled: Bool {
        guard let reason = selectedReason else { return false }
        if reason.isOther { return !otherText.trimmingCharacters(in: .whitespaces).isEmpty }
        return true
    }

    // MARK: - Sections (측정용 hidden view와 공유)

    @ViewBuilder
    private var titleSection: some View {
        Text(title)
            .fontStyle(.heading1Bold)
            .foregroundStyle(ColorSystem.labelNormalStrong)
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .padding(.bottom, 16)
    }

    @ViewBuilder
    private var optionsSection: some View {
        VStack(spacing: 20) {
            ForEach(Array(Reason.allCases), id: \.self) { reason in
                VStack(spacing: 10) {
                    ReportOption(
                        title: reason.title,
                        isSelected: selectedReason == reason,
                        onTap: {
                            selectedReason = reason
                            if !reason.isOther { isTextFocused = false }
                        }
                    )

                    if reason.isOther && selectedReason?.isOther == true {
                        CustomTextField("기타 사유를 입력해 주세요", text: $otherText)
                            .focused($isTextFocused)
                            .padding(.horizontal, 24)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
        }
        .padding(.vertical, 20)
    }

    @ViewBuilder
    private var buttonsSection: some View {
        ZStack {
            BottomOverlayGradient()
                .frame(height: 120)
                .ignoresSafeArea(edges: .bottom)
                .allowsHitTesting(false)

            HStack(spacing: 12) {
                Button(action: { isTextFocused = false; onCancel() }) {
                    Text("취소")
                        .fontStyle(.heading2Bold)
                        .foregroundStyle(ColorSystem.labelNormalNormal)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(ColorSystem.lineNormal, lineWidth: 1.25)
                        )
                }

                Button {
                    guard let reason = selectedReason else { return }
                    isTextFocused = false
                    onReasonSelected(reason, reason.isOther ? otherText : nil)
                } label: {
                    Text("신고하기")
                        .fontStyle(.heading2Bold)
                        .foregroundStyle(isSubmitEnabled ? ColorSystem.labelWhite : ColorSystem.labelNormalBasic)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(isSubmitEnabled ? ColorSystem.primaryStrong : ColorSystem.labelNormalAlternative)
                        )
                }
                .disabled(!isSubmitEnabled)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            titleSection

            ScrollView {
                optionsSection
            }
            .scrollDismissesKeyboard(.immediately)
            .animation(.easeInOut(duration: 0.2), value: selectedReason?.isOther ?? false)

            buttonsSection
        }
        .background(
            // 스크롤뷰 없이 자연 높이를 측정하는 hidden 뷰
            VStack(alignment: .leading, spacing: 0) {
                titleSection
                optionsSection
                buttonsSection
            }
            .fixedSize(horizontal: false, vertical: true)
            .hidden()
            .background(
                GeometryReader { geo in
                    Color.clear.preference(
                        key: SheetContentHeightKey.self,
                        value: geo.size.height
                    )
                }
            )
        )
        .background(ColorSystem.backgroundNormalNormal.ignoresSafeArea())
        .onTapGesture { isTextFocused = false }
        .onPreferenceChange(SheetContentHeightKey.self) { h in
            guard h > 0 else { return }
            measuredHeight = h
            if !isTextFocused {
                withAnimation(.spring(duration: 0.35)) {
                    detent = .height(h)
                }
            }
        }
        .presentationDetents(
            [.height(max(measuredHeight, 1)), .large],
            selection: $detent
        )
        .onChange(of: isTextFocused) { _, focused in
            withAnimation(.spring(duration: 0.3)) {
                detent = focused ? .large : .height(measuredHeight)
            }
        }
    }
}

private struct ReportOption: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(isSelected ? "radioSelectedIcon" : "radioUnselectedIcon", bundle: .designSystem)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)

                Text(title)
                    .fontStyle(.heading3SemiBold)
                    .foregroundStyle(ColorSystem.labelNormalNormal)

                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .buttonStyle(.plain)
    }
}
