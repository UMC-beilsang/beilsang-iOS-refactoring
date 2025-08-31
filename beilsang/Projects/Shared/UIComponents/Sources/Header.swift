//
//  Header.swift
//  UIComponentsShared
//
//  Created by Park Seyoung on 7/5/25.
//

import SwiftUI
import DesignSystemShared

public enum HeaderType {
    case primary
    case secondary(title: String, onBack: () -> Void)
    case tertiary(title: String, onBack: () -> Void, onOption: () -> Void)
}

public struct Header: View {
    private let type: HeaderType
    
    public init(type: HeaderType) {
        self.type = type
    }
    
    public var body: some View {
        VStack {
            HStack {
                switch type {
                case .primary:
                    primaryHeader
                case .secondary(let title, let onBack):
                    secondaryHeader(title: title, onBack: onBack)
                case .tertiary(let title, let onBack, let onOption):
                    tertiaryHeader(title: title, onBack: onBack, onOption: onOption)
                }
            }
            .padding(.horizontal, 24)
            
            Divider()
        }
        .frame(height: 60)
        .background(ColorSystem.backgroundNormalNormal)
    }
}

extension Header {
    private var primaryHeader: some View {
        HStack(spacing: 6) {
            Image("logoSymbol")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
            
            Image("typoLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 20)
            
            Spacer()
            
            HStack(spacing: 16) {
                Image("notificationIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 28, height: 28)
                
                Image("searchIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 28, height: 28)
            }
        }
    }
    
    private func secondaryHeader(title: String, onBack: @escaping () -> Void) -> some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(ColorSystem.labelNormalStrong)
            }
            
            Spacer()
            
            Text(title)
                .fontStyle(Fonts.heading1Bold)
                .foregroundColor(ColorSystem.labelNormalStrong)
            
            Spacer()
            
            Spacer().frame(width: 28) 
        }
    }
    
    private func tertiaryHeader(title: String, onBack: @escaping () -> Void, onOption: @escaping () -> Void) -> some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(ColorSystem.labelNormalStrong)
            }
            
            Spacer()
            
            Text(title)
                .fontStyle(Fonts.heading1Bold)
                .foregroundColor(ColorSystem.labelNormalStrong)
            
            Spacer()
            
            Button(action: onOption) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(ColorSystem.labelNormalStrong)
            }
        }
    }
}

#Preview {
    do {
        FontRegister.registerFonts()
    }
    return VStack(spacing: 20) {
        Header(type: .primary)
        Header(type: .secondary(title: "헤헤", onBack: {}))
        Header(type: .tertiary(title: "후후", onBack: {}, onOption: {}))
    }
    .previewLayout(.sizeThatFits)
}
