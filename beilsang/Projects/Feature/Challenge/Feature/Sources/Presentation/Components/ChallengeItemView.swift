//
//  ChallengeItemView.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/1/25.
//

import SwiftUI
import DesignSystemShared

struct ChallengeItemView: View {
    enum Style {
        case progress(Double)
        case participants(current: Int)
    }
    
    let challengeTitle: String
    let challengeImage: Image
    let style: Style
    let onChallengeTapped: () -> Void
    
    var body: some View {
        Button(action: { onChallengeTapped() }) {
            VStack {
                ZStack(alignment: .bottomLeading) {
                    challengeImage
                        .resizable()
                        .scaledToFill()
                    
                    GradientSystem.cardOverlay
                    
                    VStack(alignment: .leading) {
                        Spacer()
                        Text(challengeTitle)
                            .fontStyle(Fonts.body1Bold)
                            .foregroundStyle(ColorSystem.labelWhite)
                        Spacer().frame(height: 8)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
                .frame(height: UIScreen.main.bounds.height * 0.1)
                
                ZStack {
                    Rectangle()
                        .fill(ColorSystem.labelNormalDisable)
                    
                    HStack {
                        Spacer()
                        switch style {
                        case .progress(let rate):
                            Text("달성률 \(Int(rate))%")
                                .fontStyle(Fonts.detail1Medium)
                                .foregroundStyle(ColorSystem.primaryStrong)
                        case .participants(let current):
                            Text("참여인원 \(current)명")
                                .fontStyle(Fonts.detail1Medium)
                                .foregroundStyle(ColorSystem.primaryStrong)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 14)
                }
                .frame(height: UIScreen.main.bounds.height * 0.04)
            }
            .frame(width: UIScreen.main.bounds.width/2 - 31)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

struct HomeChallengeCell_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            ChallengeItemView(
                challengeTitle: "플로깅 챌린지",
                challengeImage: Image("characterGreen", bundle: .designSystem),
                style: .progress(77),
                onChallengeTapped: {}
            )
            
            ChallengeItemView(
                challengeTitle: "자전거 출퇴근",
                challengeImage: Image("characterGreen", bundle: .designSystem),
                style: .participants(current: 12),
                onChallengeTapped: {}
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
