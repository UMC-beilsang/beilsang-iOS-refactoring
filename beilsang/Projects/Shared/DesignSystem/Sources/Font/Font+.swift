//
//  Font+.swift
//  DesignSystemShared
//
//  Created by Park Seyoung on 7/5/25.
//

import SwiftUI

public extension View {
    func fontStyle(_ style: Fonts) -> some View {
        self.font(style.font)
            .kerning(style.letterSpacing)
            .lineSpacing(style.lineHeightMultiple)
    }
}
