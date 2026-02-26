//
//  GuideContentView.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/17/25.
//

import SwiftUI
import DesignSystemShared
import UIComponentsShared

struct GuideContentView: View {
    let certImages: [String]
    @State private var showImageModal = false
    @State private var selectedImageIndex = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(Array(certImages.enumerated()), id: \.offset) { index, url in
                        Image(url, bundle: .designSystem)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipped()
                            .cornerRadius(16)
                            .onTapGesture {
                                selectedImageIndex = index
                                showImageModal = true
                            }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Text("챌린지 가이드 내용")
                .fontStyle(.body2SemiBold)
                .foregroundStyle(ColorSystem.labelNormalNormal)
                .padding(.horizontal, 20)
        }
        .padding(.vertical, 20)
        .fixedSize(horizontal: false, vertical: true)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(ColorSystem.labelNormalDisable)
        )
        .fullScreenCover(isPresented: $showImageModal) {
            ImageModalView(
                assetNames: certImages,  
                selectedIndex: $selectedImageIndex,
                isPresented: $showImageModal
            )
        }
    }
}
