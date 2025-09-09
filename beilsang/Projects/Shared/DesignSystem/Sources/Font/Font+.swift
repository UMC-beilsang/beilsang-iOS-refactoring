//
//  Font+.swift
//  DesignSystemShared
//
//  Created by Park Seyoung on 7/5/25.
//

import SwiftUI

public extension View {
    func fontStyle(_ style: Fonts) -> some View {
        let size = style.fontSize
        let targetLineHeight = size * style.lineHeightMultiple
        let baselineOffset = (targetLineHeight - size) / 4

        return self.font(style.font)
            .tracking(style.letterSpacing) 
            .lineSpacing(0)
            .baselineOffset(baselineOffset)
    }
}
