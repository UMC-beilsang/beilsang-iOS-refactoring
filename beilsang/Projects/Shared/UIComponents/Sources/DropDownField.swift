//
//  DropdownField.swift
//  UIComponentsShared
//

import SwiftUI
import DesignSystemShared

public struct DropdownField<Option: Hashable>: View {
    @Binding var selected: Option?
    @State private var isExpanded = false
    
    let placeholder: String
    let options: [Option]
    let optionTitle: (Option) -> String
    
    public init(
        selected: Binding<Option?>,
        placeholder: String,
        options: [Option],
        optionTitle: @escaping (Option) -> String
    ) {
        self._selected = selected
        self.placeholder = placeholder
        self.options = options
        self.optionTitle = optionTitle
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation { isExpanded.toggle() }
            } label: {
                HStack {
                    Text(selected.map(optionTitle) ?? placeholder)
                        .foregroundColor(selected == nil ? ColorSystem.labelNormalBasic : ColorSystem.labelNormalStrong)
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
                                Text(optionTitle(option))
                                    .foregroundColor(.primary)
                                    .fontStyle(Fonts.body2Medium)
                                
                                Spacer()
                                
                                if selected == option {
                                    Image("primaryCheckIcon", bundle: .designSystem)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                }
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
