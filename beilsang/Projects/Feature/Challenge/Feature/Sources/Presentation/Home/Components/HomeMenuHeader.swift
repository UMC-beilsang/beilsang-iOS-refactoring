//
//  HomeMenuHeader.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/1/25.
//

import SwiftUI
import DesignSystemShared

struct HomeMenuHeader: View {
    let title: String
    let showAllButton: Bool
    let onShowAllTapped: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
                .frame(height: 32)
            
            HStack(alignment: .center) {
                Text(title)
                    .fontStyle(Fonts.heading2Bold)
                    .foregroundStyle(ColorSystem.labelNormalStrong)
                
                Spacer()
                
                if showAllButton {
                    Button(action: {
                        onShowAllTapped?()
                    }) {
                        HStack {
                            Text("전체보기")
                                .fontStyle(Fonts.detail1Medium)
                                .foregroundColor(ColorSystem.labelNormalBasic)
                            
                            Image("caretIcon", bundle: .designSystem)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 12, height: 12)
                        }
                    }
                }
            }
            
            Spacer()
                .frame(height: 20)
        }
    }
}

