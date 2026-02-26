//
//  ChallengeItemView.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 9/1/25.
//

import SwiftUI
import DesignSystemShared

public struct ChallengeItemView: View {
    public enum Style {
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
    
    public let title: String
    public let imageUrl: String
    public let style: Style
    public let isRecruitmentClosed: Bool
    public let onTapped: () -> Void
    
    public init(
        title: String,
        imageUrl: String,
        style: Style,
        isRecruitmentClosed: Bool = false,
        onTapped: @escaping () -> Void
    ) {
        self.title = title
        self.imageUrl = imageUrl
        self.style = style
        self.isRecruitmentClosed = isRecruitmentClosed
        self.onTapped = onTapped
    }
    
    public var body: some View {
        Button(action: onTapped) {
            VStack(spacing: 0) {
                ZStack(alignment: .bottomLeading) {
                    // 이미지 처리 (URL 또는 bundle 이미지)
                    Group {
                        if imageUrl.hasPrefix("http"),
                           let url = URL(string: imageUrl) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Rectangle()
                                    .fill(ColorSystem.labelNormalAlternative)
                            }
                        } else {
                            Image(imageUrl, bundle: .designSystem)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        }
                    }
                    .clipped()
                    .frame(height: UIScreen.main.bounds.height * 0.1)
                    .grayscale(isRecruitmentClosed ? 1.0 : 0.0) // 신청 마감 시 그레이스케일
                    
                    GradientSystem.cardOverlay
                    
                    // 신청 마감 텍스트 (오른쪽 상단)
                    if isRecruitmentClosed {
                        VStack {
                            HStack {
                                Spacer()
                                Text("신청 마감")
                                    .fontStyle(Fonts.detail1Medium)
                                    .foregroundStyle(ColorSystem.labelWhite)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(ColorSystem.primaryStrong)
                                    .cornerRadius(4)
                                    .padding(.top, 12)
                                    .padding(.trailing, 12)
                            }
                            Spacer()
                        }
                    }
                    
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

