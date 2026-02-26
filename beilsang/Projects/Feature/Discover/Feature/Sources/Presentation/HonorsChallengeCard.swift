//
//  HonorsChallengeCard.swift
//  DiscoverFeature
//
//  Created by Seyoung Park on 10/31/25.
//

import SwiftUI
import DesignSystemShared
import ModelsShared

public struct HonorsChallengeCard: View {
    private let challenge: Challenge
    private let rank: Int?
    private let action: (() -> Void)?

    public init(challenge: Challenge, rank: Int? = nil, action: (() -> Void)? = nil) {
        self.challenge = challenge
        self.rank = rank
        self.action = action
    }

    public var body: some View {
        Button(action: { action?() }) {
            ZStack(alignment: .topLeading) {
                // Thumbnail
                Group {
                    if let urlString = challenge.thumbnailImageUrl,
                       urlString.hasPrefix("http"),
                       let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Rectangle()
                                .fill(ColorSystem.lineNeutral)
                        }
                    } else if let name = challenge.thumbnailImageUrl {
                        Image(name, bundle: .designSystem)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Rectangle()
                            .fill(ColorSystem.lineNeutral)
                    }
                }
                .frame(width: 160, height: 160)
                .clipped()
                .cornerRadius(16)

                // Rank Badge
                if let rank = rank {
                    Text("\(rank)위")
                        .fontStyle(.detail1Medium)
                        .foregroundStyle(ColorSystem.labelWhite)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(ColorSystem.primaryStrong)
                        .cornerRadius(6)
                        .padding(12)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
