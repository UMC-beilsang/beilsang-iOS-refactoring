//
//  ChallengeResultView.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/10/25.
//

import SwiftUI
import DesignSystemShared

struct ChallengeResultView: View {
    let challengeSuccess: Bool
    let usePoint: Int
    let earnPoint: Int
    
    init(success: Bool, usePoint: Int, earnPoint: Int) {
        self.challengeSuccess = success
        self.usePoint = usePoint
        self.earnPoint = earnPoint
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text("나의 챌린지 결과")
                    .fontStyle(.heading3Bold)
                    .foregroundStyle(ColorSystem.labelNormalStrong)
                
                Text("이번 챌린지에서 나의 결과를 확인해 보세요!")
                    .fontStyle(.detail1Medium)
                    .foregroundStyle(ColorSystem.labelNormalBasic)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                ChallengeResultSmallView(challengeSuccess: challengeSuccess)
                
                ChallengePointView(usePoint: usePoint, earnPoint: earnPoint)
            }
        }
        .padding(.top, 28)
    }
    
    private func ChallengeResultSmallView(challengeSuccess: Bool) -> some View {
        HStack(alignment: .center, spacing: 8) {
            Image(challengeSuccess ? "challengeSuccessIcon" : "challengeFailIcon", bundle: .designSystem)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
            
            Text(challengeSuccess ? "챌린지를 성공했어요 축하드립니다!" : "챌린지를 실패했어요 다음에는 꼭 성공해요!")
                .fontStyle(.body1Bold)
                .foregroundStyle(challengeSuccess ? ColorSystem.primaryStrong : ColorSystem.semanticNegativeHeavy)
            
            Spacer()
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .stroke(challengeSuccess ? ColorSystem.primaryNeutral : ColorSystem.semanticNegativeStrong, lineWidth: 2.75)
        )
    }
    
    private func ChallengePointView(usePoint: Int, earnPoint: Int) -> some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .center, spacing: 10) {
                Image("pointNegativeIcon", bundle: .designSystem)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .center, spacing: 0) {
                    Text("사용한 포인트")
                        .fontStyle(.body2Medium)
                        .foregroundStyle(ColorSystem.labelNormalNormal)
                    
                    Text("-\(usePoint)P")
                        .fontStyle(.body1Bold)
                        .foregroundStyle(ColorSystem.semanticNegativeHeavy)
                }
            }
            .frame(maxWidth: .infinity)
            
            Rectangle()
                .fill(ColorSystem.lineNormal)
                .frame(width: 1, height: 60)

            VStack(alignment: .center, spacing: 10) {
                Image("pointIcon", bundle: .designSystem)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .center, spacing: 0) {
                    Text("획득한 포인트")
                        .fontStyle(.body2Medium)
                        .foregroundStyle(ColorSystem.labelNormalNormal)
                    
                    Text("+\(earnPoint)P")
                        .fontStyle(.body1Bold)
                        .foregroundStyle(ColorSystem.primaryStrong)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ColorSystem.labelNormalDisable)
        )
    }
}
