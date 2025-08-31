//
//  SignupTitleView.swift
//  AuthFeature
//
//  Created by Seyoung Park on 8/29/25.
//

import SwiftUI
import DesignSystemShared

struct SignupTitleView: View {
    let title: String
    
    var body: some View {
        Text(title)
            .fontStyle(Fonts.subHeading1Bold)
            .foregroundStyle(ColorSystem.labelNormalStrong)
    }
}
