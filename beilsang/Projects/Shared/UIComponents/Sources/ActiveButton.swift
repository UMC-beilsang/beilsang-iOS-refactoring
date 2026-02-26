//
//  ActiveButton.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 9/2/25.
//

import SwiftUI
import DesignSystemShared

public struct ActiveButton: View {
    private let title: String
    private let action: () -> Void
    
    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .fontStyle(Fonts.body1SemiBold)
                .foregroundColor(ColorSystem.labelNormalNormal)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 999)
                        .stroke(ColorSystem.lineNormal, lineWidth: 1.25)
                )
                .frame(width: UIScreen.main.bounds.width - 110)
        }
    }
}

struct ActiveButton_Previews: PreviewProvider {
    static var previews: some View {
        ActiveButton(title: "확인") {
            print("버튼 눌림")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
