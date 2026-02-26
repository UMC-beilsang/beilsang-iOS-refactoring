//
//  SignupCompleteView.swift
//  AuthFeature
//
//  Created by Seyoung Park on 8/30/25.
//

import SwiftUI
import UIComponentsShared
import DesignSystemShared

struct SignupCompleteView: View {
    @ObservedObject var viewModel: SignUpViewModel
    let onStart: () -> Void
    
    init(viewModel: SignUpViewModel, onStart: @escaping () -> Void = {}) {
        self.viewModel = viewModel
        self.onStart = onStart
    }
    
    var body: some View {
        ZStack {
            // 배경 Linear Gradient
            GradientSystem.primaryBackground
                .ignoresSafeArea()
            
            // 텍스트 (전경)
            VStack(spacing: 0) {
                
                Spacer().frame(height: UIScreen.main.bounds.height * 0.16)
                
                // 텍스트 섹션
                VStack(spacing: 8) {
                    VStack(spacing: 6) {
                        (
                            Text("비일상")
                                .foregroundColor(ColorSystem.primaryStrong)
                            + Text("의 새로운 회원이\n된 걸 축하합니다!")
                                .foregroundColor(ColorSystem.labelNormalStrong)
                        )
                        .fontStyle(Fonts.subHeading1Bold)
                        .multilineTextAlignment(.center)
                    }
                    
                    VStack(spacing: 4) {
                        (
                            Text("비일상")
                                .foregroundColor(ColorSystem.primaryStrong)
                            + Text("과 함께 일상에서의\n친환경을 실천해 봐요!")
                                .foregroundColor(ColorSystem.labelNormalStrong)
                        )
                        .fontStyle(Fonts.body1SemiBold)
                        .multilineTextAlignment(.center)
                    }
                    .padding(.top, 12)
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                Image("signUpCompleteImage", bundle: .designSystem)
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width)
                
                Spacer()
                
                // 시작하기 버튼
                NextStepButton(
                    title: "시작하기",
                    isEnabled: true,
                    onTap: {
                    onStart()
                }
                )
                .padding(.horizontal, 24)
                .padding(.bottom, UIScreen.main.bounds.height * 0.085)
            }
        }
    }
}
