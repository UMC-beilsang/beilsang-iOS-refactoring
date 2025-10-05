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
        case progressGrid(String)
        case participantsGrid(String)
        case progressList(progress: String, author: String)

        var width: CGFloat {
            switch self {
            case .progressGrid, .participantsGrid:
                return UIScreen.main.bounds.width / 2 - 31
            case .progressList:
                return UIScreen.main.bounds.width - 48
            }
        }

        var displayText: String {
            switch self {
            case .progressGrid(let text), .progressList(let text, _):
                return "달성률 \(text)"
            case .participantsGrid(let text):
                return "참여인원 \(text)"
            }
        }

        var authorText: String? {
            if case .progressList(_, let author) = self {
                return author
            }
            return nil
        }
    }
    
    let title: String
    let imageUrl: String
    let style: Style
    let onTapped: () -> Void
    
    var body: some View {
        Button(action: onTapped) {
            VStack(spacing: 0) {
                ZStack(alignment: .bottomLeading) {
                    Image(imageUrl, bundle: .designSystem)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                        .frame(height: UIScreen.main.bounds.height * 0.1)
                    
                    GradientSystem.cardOverlay
                    
                    Text(title)
                        .fontStyle(Fonts.body1Bold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 8)
                }
                .frame(height: UIScreen.main.bounds.height * 0.1)
                
                ZStack {
                    Rectangle()
                        .fill(ColorSystem.labelNormalDisable)
                    
                    HStack {
                        if let author = style.authorText {
                            Text(author)
                                .fontStyle(Fonts.detail1Medium)
                                .foregroundStyle(ColorSystem.labelNormalNormal)
                        }
                        
                        Spacer()
                        
                        Text(style.displayText)
                            .fontStyle(Fonts.detail1Medium)
                            .foregroundStyle(ColorSystem.primaryStrong)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 14)
                }
                .frame(height: UIScreen.main.bounds.height * 0.04)
            }
            .frame(width: style.width)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}
