//
//  EmptySearchResultView.swift
//  UIComponentsShared
//
//  Created by Seyoung
//

import SwiftUI
import DesignSystemShared

public struct EmptySearchResultView: View {
    let searchText: String
    let tips: [String]
    
    public init(
        searchText: String,
        tips: [String] = [
            "더 간결한 단어를 사용해 보세요",
            "단어마다 띄어쓰기를 사용해 보세요",
            "검색어 맞춤법을 확인해 보세요"
        ]
    ) {
        self.searchText = searchText
        self.tips = tips
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .center, spacing: 4) {
                    Text("'\(searchText)'")
                        .fontStyle(.heading3Bold)
                        .foregroundStyle(ColorSystem.primaryStrong)
                    
                    Text("검색 결과가 없습니다")
                        .fontStyle(.heading3Bold)
                        .foregroundStyle(ColorSystem.labelNormalNormal)
                    
                    Spacer()
                }
                .padding(.top, 24)
                
                Text("다른 키워드로 검색해 볼까요?")
                    .fontStyle(.body2Medium)
                    .foregroundStyle(ColorSystem.labelNormalBasic)
            }
            
            Spacer()
                .frame(height: 50)
            
            VStack(spacing: 2) {
                Image("searchResultImage", bundle: .designSystem)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(tips, id: \.self) { tip in
                        Text("• \(tip)")
                            .fontStyle(.body2Medium)
                            .foregroundStyle(ColorSystem.labelNormalBasic)
                    }
                }
            }
        }
    }
}
