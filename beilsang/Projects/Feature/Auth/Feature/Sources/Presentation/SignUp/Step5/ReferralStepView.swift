//
//  ReferralStepView.swift
//  AuthFeature
//
//  Created by Seyoung Park on 8/30/25.
//

import SwiftUI
import UIComponentsShared
import DesignSystemShared

struct ReferralStepView: View {
    @ObservedObject var viewModel: SignUpViewModel
    @FocusState private var focusedField: Field?
    private enum Field { case recommender }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            StepTitleView(title: "마지막으로 비일상을\n알게 된 경로를 알려주세요!")
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("알게된 경로")
                    .fontStyle(Fonts.heading3Bold)
                    .foregroundStyle(ColorSystem.labelNormalStrong)
                
                DropdownField(
                    selected: $viewModel.signUpData.referralInfo.source,
                    placeholder: "알게된 경로를 선택해 주세요",
                    options: ["경로1", "경로2", "경로3"],
                    optionTitle: { $0 }
                )
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("추천인 닉네임")
                    .fontStyle(Fonts.heading3Bold)
                    .foregroundStyle(ColorSystem.labelNormalStrong)
                
                CustomTextField(
                    "(선택) 추천인 닉네임을 입력해 주세요",
                    text: $viewModel.signUpData.referralInfo.recommender
                )
                .focused($focusedField, equals: .recommender)
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}
