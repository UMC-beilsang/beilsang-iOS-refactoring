//
//  CategorySmallButton.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 9/9/25.
//


import SwiftUI
import DesignSystemShared
import ModelsShared

public struct CategorySmallButton: View {
    private let keyword: Keyword
    private let action: () -> Void
    
    public init(keyword: Keyword, action: @escaping () -> Void) {
        self.keyword = keyword
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(keyword.iconName, bundle: .designSystem)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                
                Text(keyword.title)
                    .fontStyle(Fonts.body1SemiBold)
                    .foregroundColor(ColorSystem.labelNormalNormal)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ColorSystem.lineNormal, lineWidth: 1.25)
            )
        }
    }
}

struct CategorySmallButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 12) {
            CategorySmallButton(keyword: .plogging) {
                print("플로깅 눌림")
            }
            CategorySmallButton(keyword: .bicycle) {
                print("자전거 눌림")
            }
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
