//
//  ChallengeBottomButton.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/9/25.
//

import SwiftUI
import DesignSystemShared
import ModelsShared

public struct ChallengeBottomButton: View {
    let state: ChallengeDetailState
    let isLiked: Bool
    let likeCount: Int
    let onLikeTap: () -> Void
    let onMainAction: () -> Void
    
    public init(
        state: ChallengeDetailState,
        isLiked: Bool,
        likeCount: Int,
        onLikeTap: @escaping () -> Void,
        onMainAction: @escaping () -> Void
    ) {
        self.state = state
        self.isLiked = isLiked
        self.likeCount = likeCount
        self.onLikeTap = onLikeTap
        self.onMainAction = onMainAction
    }
    
    public var body: some View {
        // 정산 완료 시 바텀버튼 숨김
        if shouldShowBottomButton {
            bottomButtonContent
        }
    }
    
    private var bottomButtonContent: some View {
        HStack(alignment: .top) {
            VStack(spacing: 8) {
                Button(action: onLikeTap) {
                    Image(isLiked ? "starIconFill" : "starIcon", bundle: .designSystem)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                }
                
                Text("\(likeCount)")
                    .fontStyle(.body1Bold)
                    .foregroundStyle(ColorSystem.labelNormalNormal)
            }
            
            Spacer()
            
            Button(action: onMainAction) {
                Text(mainButtonTitle)
                    .fontStyle(.heading2Bold)
                    .foregroundStyle(mainButtonText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(mainButtonBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .frame(width: UIScreen.main.bounds.width * 0.5)
        }
        .padding(.bottom, 20)
        .padding(.horizontal, 28)
        .padding(.top, 12)
        .background(
            UnevenRoundedRectangle(
                cornerRadii: RectangleCornerRadii(
                    topLeading: 24,
                    bottomLeading: 0,
                    bottomTrailing: 0,
                    topTrailing: 24
                )
            )
            .fill(ColorSystem.labelWhite)
            .shadow(
                color: ColorSystem.decorateShadowNormal,
                radius: 7,
                x: 0, y: 0
            )
            .frame(height: UIScreen.main.bounds.height * 0.13)
        )
    }
    
    // MARK: - UI Logic Helpers
    
    /// 바텀 버튼 표시 여부
    private var shouldShowBottomButton: Bool {
        switch state {
        case .enrolled(.finished):
            return false // 정산 완료 시 바텀버튼 없음
        default:
            return true
        }
    }
    
    /// 메인 액션 버튼 활성화 여부
    private var isMainActionEnabled: Bool {
        switch state {
        case .notEnrolled(.canApply):
            return true
        case .enrolled(.inProgress(let canCertify)):
            return canCertify
        default:
            return false
        }
    }
    
    /// 메인 버튼 텍스트
    private var mainButtonTitle: String {
        switch state {
        case .notEnrolled(let notEnrolled):
            switch notEnrolled {
            case .canApply:
                return "챌린지 참여하기"
            case .applied:
                return "신청 완료"
            case .closed:
                return "모집 마감"
            }
        case .enrolled(let enrolled):
            switch enrolled {
            case .beforeStart:
                return "인증하기"
            case .inProgress(let canCertify):
                return canCertify ? "인증하기" : "인증 완료"
            case .calculating:
                return "챌린지 종료"
            case .finished(let success):
                return ""
            }
        }
    }
    
    private var mainButtonBackground: Color {
        isMainActionEnabled ? ColorSystem.primaryStrong : ColorSystem.labelNormalAlternative
    }
    
    private var mainButtonText: Color {
        isMainActionEnabled ? ColorSystem.labelWhite : ColorSystem.labelNormalBasic
    }
}
