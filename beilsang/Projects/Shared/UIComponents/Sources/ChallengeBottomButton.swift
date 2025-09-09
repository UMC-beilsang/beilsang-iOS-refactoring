//
//  ChallengeBottomButton.swift
//  UIComponentsShared
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
        HStack(alignment: .center) {
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
            .disabled(!isMainActionEnabled)
            .frame(width: UIScreen.main.bounds.width * 0.5)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 12)
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
            .frame(height: UIScreen.main.bounds.height * 0.11)
        )
    }
    
    // MARK: - Helpers
    private var mainButtonTitle: String {
        switch state {
        case .enrolled(let enrolled):
            switch enrolled {
            case .beforeStart:
                return "참여중"
            case .inProgress(let canCertify):
                return canCertify ? "인증하기" : "오늘은 완료!"
            case .finished(let success):
                return success ? "챌린지 성공" : "챌린지 실패"
            }
        case .notEnrolled(let notEnrolled):
            switch notEnrolled {
            case .canApply:
                return "참여하기"
            case .applied:
                return "신청 완료"
            case .closed:
                return "마감됨"
            }
        }
    }
    
    private var isMainActionEnabled: Bool {
        switch state {
        case .enrolled(let enrolled):
            switch enrolled {
            case .inProgress(let canCertify):
                return canCertify
            default:
                return false
            }
        case .notEnrolled(let notEnrolled):
            switch notEnrolled {
            case .canApply:
                return true
            default:
                return false
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
