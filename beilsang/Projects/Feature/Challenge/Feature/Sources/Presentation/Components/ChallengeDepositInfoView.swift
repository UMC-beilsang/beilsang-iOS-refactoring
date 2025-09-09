//
//  ChallengeDepositInfoView.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/2/25.
//

import SwiftUI
import DesignSystemShared

struct ChallengeDepositInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("보상 포인트 안내")
                .fontStyle(.heading3Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)
            
            VStack(alignment: .center, spacing: 8) {
                Spacer()
                
                Image("pointIcon", bundle: .designSystem)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .center, spacing: 2) {
                    Text("챌린지를 실패한 챌린저의 포인트를 합산 후")
                        .fontStyle(.body2Medium)
                        .foregroundStyle(ColorSystem.labelNormalNormal)
                    
                    Text("성공한 챌린저와 포인트를 나누어 지급")
                        .fontStyle(.body1Bold)
                        .foregroundStyle(ColorSystem.primaryStrong)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(ColorSystem.labelNormalDisable)
            )
        }
        .padding(.top, 28)
    }
}
