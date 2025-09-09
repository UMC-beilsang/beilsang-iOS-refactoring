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
            .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 4)
    }
}

struct HomeMainCardCrousel: View {
    let images = ["thumbnailBanner1", "thumbnailBanner2", "thumbnailBanner3"]
    
    var body: some View {
        TabView {
            ForEach(images, id: \.self) { image in
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
