//
//  SignupProgressView.swift
//  AuthFeature
//
//  Created by Seyoung Park on 8/29/25.
//

import SwiftUI
import DesignSystemShared

struct SignupProgressView: View {
    let currentStep: SignUpStep
    let totalSteps: Int
    
    var body: some View {
        HStack(spacing: 5) {
            ForEach(Array(SignUpStep.allCases.prefix(totalSteps)), id: \.self) { step in
                HStack(spacing: 5) {
                    signupProgressButton(step: step)
                    
                    if step != Array(SignUpStep.allCases.prefix(totalSteps)).last {
                        separatorDots(step: step)
                    }
                }
            }
        }
    }
    
    private func signupProgressButton(step: SignUpStep) -> some View {
        let isActive = step == currentStep
        let isCompleted = step.rawValue < currentStep.rawValue
        
        return ZStack {
            Circle()
                .fill(isActive ? ColorSystem.primaryStrong
                               : isCompleted ? ColorSystem.primaryNeutral
                                             : Color.clear)
                .frame(width: 28, height: 28)
                .overlay(
                    Circle()
                        .stroke(isActive || isCompleted ? Color.clear
                                                        : ColorSystem.labelNormalAlternative,
                                lineWidth: 1)
                )
            if isCompleted {
                Image("normalCheckIcon", bundle: .designSystem)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                
            } else {
                Text("\(step.rawValue + 1)")
                    .font(.custom("NPS-font-Regular", size: 14))
                    .foregroundColor(isActive || isCompleted
                                     ? ColorSystem.labelWhite
                                     : ColorSystem.labelNormalBasic)
            }
        }
        .shadow(radius: isActive ? 6 : 0)
    }

    
    private func separatorDots(step: SignUpStep) -> some View {
        let isPassedOrActive = step.rawValue <= currentStep.rawValue
        let color = isPassedOrActive ? ColorSystem.primaryStrong : ColorSystem.labelNormalAlternative
        
        return HStack(spacing: 2) {
            Circle().fill(color).frame(width: 2, height: 2)
            Circle().fill(color).frame(width: 2, height: 2)
            Circle().fill(color).frame(width: 2, height: 2)
        }
    }

}

#Preview {
    do {
        FontRegister.registerFonts()
    }
    return SignupProgressView(
        currentStep: SignUpStep(rawValue: 1) ?? .terms,
        totalSteps: SignUpStep.allCases.count
    )
}

