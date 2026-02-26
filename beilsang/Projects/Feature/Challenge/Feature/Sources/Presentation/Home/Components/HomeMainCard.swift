//
//  HomeMainCard.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/1/25.
//

import SwiftUI
import DesignSystemShared

struct HomeMainCard: View {
    let imageName: String
    
    var body: some View {
        Image(imageName, bundle: .designSystem)
            .resizable()
            .scaledToFit()
            .frame(width: UIScreen.main.bounds.width - 48,
                               height: UIScreen.main.bounds.height * 0.26)
            .clipped()
            .cornerRadius(24)
    }
}

struct HomeMainCardCrousel: View {
    // 같은 이미지라도 SwiftUI ForEach ID는 유니크해야 해서 인덱스를 ID로 사용
    let images = ["thumbnailBanner1", "thumbnailBanner1", "thumbnailBanner1"]
    
    var body: some View {
        TabView {
            ForEach(Array(images.enumerated()), id: \.offset) { _, image in
                HomeMainCard(imageName: image)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .frame(height: UIScreen.main.bounds.height * 0.26)
    }
}

struct HomeMainCardCarousel_Previews: PreviewProvider {
    static var previews: some View {
        HomeMainCardCrousel()
            .padding()
    }
}
