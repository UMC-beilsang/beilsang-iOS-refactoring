//
//  FeedThumbnailCard.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 10/31/25.
//

import Foundation
//
//  FeedThumbnailCard.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 11/1/25.
//

import SwiftUI
import DesignSystemShared
import ModelsShared

public struct FeedThumbnailCard: View {
    private let imageUrl: String?
    private let isMyFeed: Bool
    private let onTap: () -> Void

    public init(imageUrl: String?, isMyFeed: Bool = false, onTap: @escaping () -> Void) {
        self.imageUrl = imageUrl
        self.isMyFeed = isMyFeed
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: imageUrl ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(1.3, contentMode: .fill)
                        .cornerRadius(16)
                } placeholder: {
                    Rectangle()
                        .fill(ColorSystem.lineNeutral)
                        .aspectRatio(1.3, contentMode: .fill)
                        .cornerRadius(16)
                }

                if isMyFeed {
                    Text("내 사진")
                        .fontStyle(.detail1Medium)
                        .foregroundColor(ColorSystem.labelWhite)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(ColorSystem.primaryStrong)
                        .cornerRadius(4)
                        .padding(10)
                }
            }
            .clipped()
        }
        .buttonStyle(.plain)
    }
}
