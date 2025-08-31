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
        "photo.on.rectangle.angled",
        "camera.fill",
        "heart.fill",
        "star.fill"
    ]
    
    private let titles = [
        "새로운 시작",
        "함께하는 여정",
        "성장하는 습관",
        "특별한 경험"
    ]
    
    private let descriptions = [
        "당신의 새로운 시작을\n응원합니다",
        "함께 성장하는\n특별한 여정",
        "작은 습관이 만드는\n큰 변화",
        "매일이 특별해지는\n경험을 시작하세요"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // 이미지 캐러셀
            TabView(selection: $currentIndex) {
                ForEach(0..<images.count, id: \.self) { index in
                    VStack(spacing: 24) {
                        Image(systemName: images[index])
                            .font(.system(size: 120, weight: .light))
                            .foregroundColor(.blue)
                        
                        VStack(spacing: 12) {
                            Text(titles[index])
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text(descriptions[index])
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                        }
                        .padding(.horizontal, 40)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onAppear {
                startAutoSlide()
            }
            
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
            .padding(.top, 20)
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
