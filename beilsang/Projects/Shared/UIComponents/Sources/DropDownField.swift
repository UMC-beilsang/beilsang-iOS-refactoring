//
//  DropdownField.swift
//  UIComponentsShared
//

import SwiftUI
import DesignSystemShared

public struct DropdownField: View {
    @Binding var selected: String
    @State private var isExpanded = false
    
    let placeholder: String
    let options: [String]
    
    public init(
        selected: Binding<String>,
        placeholder: String,
        options: [String]
    ) {
        self._selected = selected
        self.placeholder = placeholder
        self.options = options
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // 메인 버튼
            Button {
                withAnimation { isExpanded.toggle() }
            } label: {
                HStack {
                    Text(selected.isEmpty ? placeholder : selected)
                        .foregroundColor(selected.isEmpty ? ColorSystem.labelNormalBasic : ColorSystem.labelNormalStrong)
                        .fontStyle(Fonts.body2Medium)
                    
                    Spacer()
                    Image("dropDownIcon", bundle: .designSystem)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                .padding(.horizontal, 12)
                .frame(height: 48)
                .background(ColorSystem.labelNormalDisable)
                .cornerRadius(8)
            }
            
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(options, id: \.self) { option in
                        Button {
                            selected = option
                            withAnimation { isExpanded = false }
                        } label: {
                            HStack {
                                Text(option)
                                    .foregroundColor(.primary)
                                    .fontStyle(Fonts.body2Medium)
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .frame(height: 48)
                        }
                    }
                }
                .background(AtomicColor.common0)
                .cornerRadius(8)
                .shadow(radius: 2)
                .padding(.top, 4)
            }
        }
    }
}
