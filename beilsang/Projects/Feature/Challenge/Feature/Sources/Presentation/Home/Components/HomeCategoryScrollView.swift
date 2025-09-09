//
//  HomeCategoryScrollView.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/1/25.
//

import SwiftUI
import ModelsShared
import DesignSystemShared

struct HomeCategoryScrollView: View {
    let onCategoryTapped: (Keyword) -> Void
    
    private let rows: [GridItem] = [
        GridItem(.fixed(80), spacing: 8),
        GridItem(.fixed(80), spacing: 8)
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: rows, spacing: 8) {
                ForEach(Keyword.allCases, id: \.self) { keyword in
                    Button {
                        onCategoryTapped(keyword)
                    } label: {
                        VStack(spacing: 8) {
                            Image(keyword.iconName, bundle: .designSystem)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 36, height: 36)
                            
                            Text(keyword.title)
                                .fontStyle(Fonts.detail1Medium)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: 80, height: 80)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(ColorSystem.labelNormalDisable)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)
        }
    }
}

struct HomeCategoryScrollView_Previews: PreviewProvider {
    static var previews: some View {
        HomeCategoryScrollView { keyword in
            print("\(keyword.title) tapped")
        }
    }
}
