//
//  Header.swift
//  UIComponentsShared
//
//  Created by Park Seyoung on 7/5/25.
//

import SwiftUI
import DesignSystemShared

public enum HeaderType {
    case primary(onNotification: () -> Void, onSearch: () -> Void)
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
            
            Spacer()
            
            HStack {
                switch type {
                case  .primary(let onNotification, let onSearch):
                    primaryHeader(onNotification: onNotification, onSearch: onSearch)
                case .secondary(let title, let onBack):
                    secondaryHeader(title: title, onBack: onBack)
                case .tertiary(let title, let onBack, let onOption):
                    tertiaryHeader(title: title, onBack: onBack, onOption: onOption)
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            Divider()
        }
        .frame(height: 60)
        .background(ColorSystem.backgroundNormalNormal)
    }
}

extension Header {
    private func primaryHeader(
        onNotification: @escaping () -> Void,
        onSearch: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 6) {
//            Image("logoSymbol", bundle: .designSystem)
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 32, height: 32)
//            
//            Image("typoLogo", bundle: .designSystem)
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(height: 20)
            
            Spacer()
            
            HStack(spacing: 16) {
                Button(action: onNotification) {
                    Image("notificationIcon", bundle: .designSystem)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
                
                Button(action: onSearch) {
                    Image("searchIcon", bundle: .designSystem)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
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
            
            Menu {
                Button("신고하기", action: onOption)
                
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(ColorSystem.labelNormalStrong)
            }
            .buttonStyle(.plain)
        }
    }
}
