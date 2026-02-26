//
//  SwipeableImageCarousel.swift
//  AuthFeature
//
//  Created by SeyoungPark on 8/28/25.
//

import SwiftUI
import DesignSystemShared

struct SwipeableImageCarousel: View {
    @State private var currentIndex = 0
    
    private let images = [
        "onboardingImage1",
        "onboardingImage2",
        "onboardingImage3"
    ]
    
    private let titles = [
        "다양한 챌린지에 참여할 수 있어요!",
        "챌린지를 직접 만들 수 있어요!",
        "활동 배지를 모아 보아요!"
    ]
    
    var body: some View {
        let imageHeight = UIScreen.main.bounds.height * 0.56
        
        VStack(spacing: 0) {
            // 이미지 캐러셀 - 상단부터 꽉 채움
            TabView(selection: $currentIndex) {
                ForEach(0..<images.count, id: \.self) { index in
                    Image(images[index], bundle: .designSystem)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: imageHeight, alignment: .top)
                        .clipped()
                        .background(Color.cyan)
                        .tag(index)
                        .ignoresSafeArea(edges: .top)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: imageHeight)
            .onAppear {
                startAutoSlide()
            }
            
            Spacer()
            
            // 타이틀
            Text(titles[currentIndex])
                .fontStyle(.heading2Bold)
                .foregroundColor(ColorSystem.labelNormalNormal)
                .multilineTextAlignment(.center)
                .animation(.easeInOut(duration: 0.3), value: currentIndex)
            
            Spacer()
            
            // 페이지 인디케이터
            HStack(spacing: 8) {
                ForEach(0..<images.count, id: \.self) { index in
                    Capsule()
                        .fill(index == currentIndex ? ColorSystem.primaryStrong : ColorSystem.labelNormalAlternative)
                        .frame(
                            width: index == currentIndex ? 24 : 8,
                            height: 8
                        )
                        .animation(.easeInOut(duration: 0.3), value: currentIndex)
                }
            }
            .padding(.bottom, 24)
        }
    }
    
    private func startAutoSlide() {
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentIndex = (currentIndex + 1) % images.count
            }
        }
    }
}

#Preview {
    SwipeableImageCarousel()
        .frame(height: 400)
}
