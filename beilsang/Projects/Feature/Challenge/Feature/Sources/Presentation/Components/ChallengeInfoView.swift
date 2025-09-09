//
//  ChallengeInfoView.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/2/25.
//

import SwiftUI
import UIComponentsShared
import DesignSystemShared
import ChallengeDomain
import ModelsShared

struct ChallengeInfoView: View {
    let state: ChallengeDetailState
    let dDayText: String
    let startDateText: String
    let depositText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            switch state {
            case .notEnrolled:
                VStack(alignment: .leading, spacing: 12) {
                    ChallengeInfoRow(title: "시작일") {
                        HStack(spacing: 10) {
                            Text(dDayText)
                                .fontStyle(.body2SemiBold)
                                .foregroundStyle(ColorSystem.labelWhite)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(ColorSystem.primaryStrong)
                                )
                            
                            Text(startDateText)
                                .fontStyle(.body1Bold)
                                .foregroundStyle(ColorSystem.labelNormalStrong)
                        }
                    }
                    
                    ChallengeInfoRow(title: "참여 포인트") {
                        HStack(spacing: 10) {
                            Text(depositText)
                                .fontStyle(.body1Bold)
                                .foregroundStyle(ColorSystem.primaryStrong)
                        }
                    }
                }
                
            case .enrolled:
                ChallengeInfoRow(title: "진행도") {
                    HStack(spacing: 10) {
                        // TODO: 연결 필요
                        ProgressBar(value: 0.3)
                    }
                }
            }
            
            ChallengeWeeklyGoalView()
        }
        .padding(.top, 32)
    }
}

private struct ChallengeWeeklyGoalView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 8) {
                Image("clockIcon", bundle: .designSystem)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                
                Text("실천 기간")
                    .fontStyle(.body1Bold)
                    .foregroundStyle(ColorSystem.labelNormalStrong)
                
                Spacer()
            }
            
            HStack(alignment: .center, spacing: 0) {
                // TODO: - 이것도 추가해야함
                Text("시작일로부터 ")
                
                Text("일주일동안 5회")
                    .foregroundStyle(ColorSystem.primaryStrong)
                
                Text(" 진행")
            }
            .fontStyle(.body2SemiBold)
            .foregroundStyle(ColorSystem.labelNormalNormal)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(ColorSystem.labelNormalDisable)
        )
    }
}
