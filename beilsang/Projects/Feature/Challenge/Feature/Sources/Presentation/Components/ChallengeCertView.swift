//
//  ChallengeCertView.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/2/25.
//

import SwiftUI
import DesignSystemShared

struct ChallengeCertView: View {
    let certImages: [String]
    @State private var showImageModal = false
    @State private var selectedImageIndex = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text("챌린지 인증 유의사항")
                    .fontStyle(.heading3Bold)
                    .foregroundStyle(ColorSystem.labelNormalStrong)
                
                Text("아래 챌린지 모범 인증 사진을 확인해 보세요!")
                    .fontStyle(.detail1Medium)
                    .foregroundStyle(ColorSystem.labelNormalBasic)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 12) {
                        ForEach(Array(certImages.enumerated()), id: \.offset) { index, url in
                            // **TODO: - URL이미지 사용**
                            Image(url, bundle: .designSystem)
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.height * 0.17,
                                       height: UIScreen.main.bounds.height * 0.17)
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
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(ColorSystem.labelNormalDisable)
            )
        }
        .padding(.top, 28)
        .fullScreenCover(isPresented: $showImageModal) {
            CertImageModalView(
                certImages: certImages,
                selectedIndex: $selectedImageIndex,
                isPresented: $showImageModal
            )
        }
    }
}

struct CertImageModalView: View {
    let certImages: [String]
    @Binding var selectedIndex: Int
    @Binding var isPresented: Bool
    @State private var currentOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with close button
                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("\(selectedIndex + 1) / \(certImages.count)")
                        .fontStyle(.body2Medium)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                // Image ScrollView
                TabView(selection: $selectedIndex) {
                    ForEach(Array(certImages.enumerated()), id: \.offset) { index, url in
                        ZStack {
                            // **TODO: - URL이미지 사용**
                            Image(url, bundle: .designSystem)
                                .resizable()
                                .scaledToFit()
                                .tag(index)
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                Spacer()
                
                // Bottom indicator dots
                HStack(spacing: 8) {
                    ForEach(0..<certImages.count, id: \.self) { index in
                        Circle()
                            .fill(selectedIndex == index ? Color.white : Color.white.opacity(0.4))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut(duration: 0.2), value: selectedIndex)
                    }
                }
                .padding(.bottom, 50)
            }
        }
    }
}
