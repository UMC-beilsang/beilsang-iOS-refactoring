//
//  MottoSelectionStepView.swift
//  AuthFeature
//
//  Created by Park Seyoung on 8/28/25.
//

import SwiftUI
import UIComponentsShared
import DesignSystemShared

struct MottoSelectionStepView: View {
    @ObservedObject var viewModel: SignUpViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SignupTitleView(title: "비일상을 통해 이루고 싶은\n다짐을 선택해 주세요!")
            
            Spacer()
            
            VStack(spacing: 12) {
                ForEach(viewModel.availableMottos) { motto in
                    MottoItemView(
                        title: motto.title,
                        iconName: motto.iconName,
                        isSelected: viewModel.selectedMotto == motto,
                        hasAnySelection: viewModel.selectedMotto != nil,
                        onTap: { viewModel.selectMotto(motto) }
                    )
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}
