//
//  CustomTextField.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 8/30/25.
//

import SwiftUI
import DesignSystemShared

public struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    
    public init(
        _ placeholder: String,
        text: Binding<String>
    ) {
        self.placeholder = placeholder
        self._text = text
    }
    
    public var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(ColorSystem.labelNormalBasic)
                    .fontStyle(Fonts.body2Medium)
                    .padding(.leading, 12)
                    .allowsHitTesting(false)
            }
            
            TextField("", text: $text)
                .padding(.horizontal, 12)
                .fontStyle(Fonts.body2Medium)
        }
        .frame(height: 48)
        .background(ColorSystem.labelNormalDisable)
        .cornerRadius(8)
    }
}
