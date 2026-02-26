//
//  StepTitleView.swift
//  AuthFeature
//
//  Created by Seyoung Park on 8/29/25.
//

import SwiftUI
import DesignSystemShared

public struct StepTitleView: View {
    private let title: String
    
    public init(title: String) {
        self.title = title
    }
    
    public var body: some View {
        Text(title)
            .fontStyle(Fonts.subHeading1Bold)
            .foregroundStyle(ColorSystem.labelNormalStrong)
    }
}
