//
//  KeywordSelectionStepView.swift
//  AuthFeature
//
//  Created by Park Seyoung on 8/28/25.
//

import SwiftUI
import UIComponentsShared
import DesignSystemShared

struct KeywordSelectionStepView: View {
    @ObservedObject var viewModel: SignUpViewModel
    
    private let spacing: CGFloat = 10
    private let horizontalPadding: CGFloat = 24
    private let columns = 3
    
    var body: some View {
        let totalSpacing = spacing * CGFloat(columns - 1)
        let totalPadding = horizontalPadding * 2
        let itemWidth = (UIScreen.main.bounds.width - totalPadding - totalSpacing) / CGFloat(columns)
        
        let filteredKeywords = viewModel.availableKeywords.filter { $0 != .all }
        
        VStack(alignment: .leading, spacing: 20) {
            StepTitleView(title: "친환경 키워드를\n한 가지 선택해 주세요!")
            
            Spacer()
            
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(itemWidth), spacing: spacing), count: columns), spacing: spacing) {
                ForEach(filteredKeywords, id: \.self) { keyword in
                    KeywordItemView(
                        title: keyword.title,
                        defaultIconName: keyword.iconName + "Default",
                        selectedIconName: keyword.iconName,
                        isSelected: viewModel.selectedKeyword == keyword,
                        hasAnySelection: viewModel.selectedKeyword != nil,
                        onTap: { viewModel.toggleKeyword(keyword) },
                        itemSize: itemWidth
                    )
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, horizontalPadding)
    }
}
