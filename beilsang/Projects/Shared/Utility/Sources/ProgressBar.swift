//
//  ProgressBar.swift
//  UtilityShared
//
//  Created by Seyoung Park on 9/9/25.
//

import SwiftUI
import DesignSystemShared

public struct ProgressBar: View {
    let value: Double  // 0.0 ~ 1.0
    
    public init(value: Double) {
        self.value = value
    }
    
    public var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 10)
                    .fill(ColorSystem.labelNormalDisable)
                    .frame(height: 20)
                
                // Fill
                RoundedRectangle(cornerRadius: 10)
                    .fill(ColorSystem.primaryStrong)
                    .frame(width: geo.size.width * CGFloat(value),
                           height: 20)
            }
        }
        .frame(height: 20)
    }
}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            ProgressBar(value: 0.3)
            ProgressBar(value: 0.6)
            ProgressBar(value: 1.0)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
