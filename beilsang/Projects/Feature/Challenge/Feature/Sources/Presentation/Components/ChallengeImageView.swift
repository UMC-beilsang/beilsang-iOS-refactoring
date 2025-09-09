//
//  ChallengeImageView.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/2/25.
//

import SwiftUI
import UIComponentsShared
import DesignSystemShared

struct ChallengeImageView: View {
    let imageURL: String
    let participantText: String
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(imageURL, bundle: .designSystem)
                .resizable()
                .scaledToFill()
                .frame(height: UIScreen.main.bounds.height * 0.32)
                .clipped()
            
            ChallengeParticipantsView(participantText: participantText)
                .padding(.trailing, 16)
                .padding(.bottom, 12)
        }
    }
}

private struct ChallengeParticipantsView: View {
    let participantText: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image("userIcon", bundle: .designSystem)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height:20)
            
            Text("\(participantText) 참여중")
                .fontStyle(.body2Medium)
                .foregroundStyle(ColorSystem.labelWhite)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 999)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 999)
                    .fill(ColorSystem.decorateScrimNormal)
            }
        }
    }
}
