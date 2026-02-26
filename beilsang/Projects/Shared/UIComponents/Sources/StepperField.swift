//
//  StepperField.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 10/3/25.
//

import SwiftUI
import DesignSystemShared

public struct StepperField: View {
    let value: Int
    let minValue: Int
    let maxValue: Int
    let step: Int
    let unitText: (Int) -> String
    let onIncrease: () -> Void
    let onDecrease: () -> Void
    
    public init(
        value: Int,
        minValue: Int,
        maxValue: Int,
        step: Int = 1,
        unitText: @escaping (Int) -> String,
        onIncrease: @escaping () -> Void,
        onDecrease: @escaping () -> Void
    ) {
        self.value = value
        self.minValue = minValue
        self.maxValue = maxValue
        self.step = step
        self.unitText = unitText
        self.onIncrease = onIncrease
        self.onDecrease = onDecrease
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Button(action: onDecrease) {
                    Image(value > minValue ? "minusIcon" : "minusDisableIcon", bundle: .designSystem)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .frame(height: 48)
                        .frame(maxWidth: .infinity)
                        .background(value > minValue ? ColorSystem.primaryStrong : ColorSystem.labelNormalDisable)
                        .cornerRadius(8)
                }
                .disabled(value <= minValue)
                
                Text("\(value)")
                    .frame(width: UIScreen.main.bounds.height * 0.16, height: 48)
                    .background(ColorSystem.labelNormalDisable)
                    .foregroundStyle(ColorSystem.labelNormalStrong)
                    .fontStyle(.body2Medium)
                    .cornerRadius(8)
                
                Button(action: onIncrease) {
                    Image(value < maxValue ? "plusIcon" : "plusDisableIcon", bundle: .designSystem)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .frame(height: 48)
                        .frame(maxWidth: .infinity)
                        .background(value < maxValue ? ColorSystem.primaryStrong : ColorSystem.labelNormalDisable)
                        .cornerRadius(8)
                }
                .disabled(value >= maxValue)
            }
            
            Text(unitText(value))
                .fontStyle(.detail2Regular)
                .foregroundStyle(value == minValue ? ColorSystem.labelNormalBasic : ColorSystem.semanticPositiveHeavy)
        }
    }
}
