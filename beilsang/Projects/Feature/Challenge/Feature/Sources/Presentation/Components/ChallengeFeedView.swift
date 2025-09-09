//
//  ChallengeFeedView.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/2/25.
//

import SwiftUI
import DesignSystemShared

struct ChallengeFeedView: View {
    let onSeeAllTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("인증 갤러리")
                        .fontStyle(.heading3Bold)
                        .foregroundStyle(ColorSystem.labelNormalStrong)
                    
                    Text("함께하는 챌린지들의 이야기를 확인해 보세요!")
                        .fontStyle(.detail1Medium)
                        .foregroundStyle(ColorSystem.labelNormalBasic)
                }
                
                Spacer()
                
                Button(action: onSeeAllTap) {
                    HStack(alignment: .center) {
                        Text("전체보기")
                            .fontStyle(.detail1Medium)
                            .foregroundStyle(ColorSystem.labelNormalBasic)
                        
                        Image("caretIcon", bundle: .designSystem)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                    }
                }
            }
            
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 2),
                spacing: 14
            ) {
                ForEach(0..<4, id: \.self) { index in
                    Image("challengeThumbnail2", bundle: .designSystem) // TODO: 실제 URL/이미지로 교체
                        .resizable()
                        .frame(width: (UIScreen.main.bounds.width)/2 - 24 - 7, height: UIScreen.main.bounds.height * 0.15)
                        .scaledToFill()
                        .clipped()
                        .cornerRadius(12)
                }
            }
        }
        .padding(.top, 28)
    }
}
