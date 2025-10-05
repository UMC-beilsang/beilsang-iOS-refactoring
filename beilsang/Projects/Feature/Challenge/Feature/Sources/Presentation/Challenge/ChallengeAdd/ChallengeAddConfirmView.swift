//
//  ChallengeAddConfirmView.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 10/4/25.
//

import SwiftUI
import UIComponentsShared
import DesignSystemShared
import ModelsShared

struct ChallengeAddConfirmView: View {
    @ObservedObject var viewModel: ChallengeAddViewModel
    @EnvironmentObject var toastManager: ToastManager
    
    var body: some View {
        VStack(alignment: .leading) {
            StepTitleView(title: "잠깐! 마지막으로\n아래 유의사항을 체크해 주세요!")
            
            Spacer(minLength: UIScreen.main.bounds.height * 0.06)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(Array(viewModel.confirmList.enumerated()), id: \.offset) { index, item in
                        SelectableItemView(
                            title: item,
                            isSelected: viewModel.isCheckListItemSelected(at: index),
                            hasAnySelection: viewModel.hasAnyCheckListSelection,
                            onTap: {
                                viewModel.toggleCheckListItem(at: index)
                            }
                        )
                    }
                }
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .padding(.horizontal, 24)
    }
}
