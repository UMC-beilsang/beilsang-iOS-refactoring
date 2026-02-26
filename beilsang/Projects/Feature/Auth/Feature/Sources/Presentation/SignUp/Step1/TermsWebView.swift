//
//  TermsWebView.swift
//  AuthFeature
//
//  Created by Park Seyoung on 8/28/25.
//

import SwiftUI
import UIComponentsShared

public struct TermsWebView: View {
    let termsType: TermsType
    @Environment(\.dismiss) private var dismiss
    
    public init(termsType: TermsType) {
        self.termsType = termsType
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            Header(type: .secondary(title: termsType.title, onBack: {
                dismiss()
            }))
            
            // TODO: 여기에 웹뷰 추가
            Spacer()
            
            Text("웹뷰가 들어갈 자리")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

#Preview {
    TermsWebView(termsType: .service)
}
