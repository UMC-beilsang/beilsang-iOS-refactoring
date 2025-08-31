//
//  AgreeTermsView.swift
//  AuthFeature
//
//  Created by Seyoung Park on 8/29/25.
//

import SwiftUI
import UIComponentsShared
import DesignSystemShared

struct AgreeTermsStepView: View {
    @ObservedObject var viewModel: SignUpViewModel
    @EnvironmentObject var toastManager: ToastManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SignupTitleView(title: "비일상을 시작하기 위해\n약관을 동의해 주세요")
            
            Spacer()
            
            VStack {
                
                allAgreeButton
                
                Spacer().frame(height: 20)
                
                SignupAgreeButton(
                    title: "이용약관 동의",
                    isRequired: true,
                    isChecked: viewModel.terms.service,
                    onTap: { viewModel.toggleServiceAgree() },
                    onShowTerms: { viewModel.showServiceTerms() }
                )
                
                SignupAgreeButton(
                    title: "개인정보 수집 및 이용 동의",
                    isRequired: true,
                    isChecked: viewModel.terms.privacy,
                    onTap: { viewModel.togglePrivacyAgree() },
                    onShowTerms: { viewModel.showPrivacyTerms() }
                )
                
                SignupAgreeButton(
                    title: "선택 약관",
                    isRequired: false,
                    isChecked: viewModel.terms.marketing,
                    onTap: { viewModel.toggleMarketingAgree() },
                    onShowTerms: { viewModel.showMarketingTerms() }
                )
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .fullScreenCover(item: $viewModel.showTermsSheet) { termsType in
            TermsWebView(termsType: termsType)
        }
    }
    
    private var allAgreeButton: some View {
        Button(action : { viewModel.toggleAllAgree() }) {
            HStack {
                Image(viewModel.terms.allAgreed ? "agreeCheckIconSelected" : "agreeCheckIcon", bundle: .designSystem)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                
                Text("약관 모두 동의하기")
                    .fontStyle(Fonts.heading3Bold)
                    .foregroundStyle(ColorSystem.labelNormalStrong)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(minHeight: 68)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(ColorSystem.labelNormalDisable)
            )
        }
    }
}

