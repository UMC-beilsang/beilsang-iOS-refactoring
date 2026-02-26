//
//  StepProgressView.swift
//  AuthFeature
//
//  Created by Seyoung Park on 8/29/25.
//

import SwiftUI
import DesignSystemShared

public struct StepProgressView: View {
    private let currentIndex: Int   
    private let totalSteps: Int
    
    public init(currentIndex: Int, totalSteps: Int) {
        self.currentIndex = currentIndex
        self.totalSteps = totalSteps
    }
    
    public var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<totalSteps, id: \.self) { index in
                HStack(spacing: 5) {
                    progressCircle(index: index)
                    
                    if index != totalSteps - 1 {
                        separatorDots(index: index)
                    }
                }
            }
        }
    }
    
    private func progressCircle(index: Int) -> some View {
        let isActive = index == currentIndex
        let isCompleted = index < currentIndex
        
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
                Text("\(index + 1)")
                    .font(.custom("NPS-font-Regular", size: 14))
                    .foregroundColor(isActive || isCompleted
                                     ? ColorSystem.labelWhite
                                     : ColorSystem.labelNormalBasic)
            }
        }
        .shadow(radius: isActive ? 6 : 0)
    }
    
    private func separatorDots(index: Int) -> some View {
        let isPassedOrActive = index <= currentIndex
        let color = isPassedOrActive ? ColorSystem.primaryStrong : ColorSystem.labelNormalAlternative
        
        return HStack(spacing: 2) {
            ForEach(0..<3, id: \.self) { _ in
                Circle().fill(color).frame(width: 2, height: 2)
            }
        }
    }
}

#Preview {
    StepProgressView(
        currentIndex: 1,
        totalSteps: 5
    )
}
