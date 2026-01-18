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
    case primaryTitle(title: String, onNotification: () -> Void, onSearch: () -> Void)
    case secondary(title: String, onBack: () -> Void)
    case secondaryWithSave(title: String, onBack: () -> Void, onSave: () -> Void, canSave: Bool)
    case tertiaryReport(title: String, onBack: () -> Void, onOption: () -> Void)
    case tertiaryMenu(title: String, onBack: () -> Void, menuTitle: String, onMenuAction: () -> Void)
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
                case .primaryTitle(let title, let onNotification, let onSearch):
                    primaryTitleHeader(title: title, onNotification: onNotification, onSearch: onSearch)
                case .secondary(let title, let onBack):
                    secondaryHeader(title: title, onBack: onBack)
                case .secondaryWithSave(let title, let onBack, let onSave, let canSave):
                    secondaryWithSaveHeader(title: title, onBack: onBack, onSave: onSave, canSave: canSave)
                case .tertiaryReport(let title, let onBack, let onOption):
                    tertiaryReportHeader(title: title, onBack: onBack, onOption: onOption)
                case .tertiaryMenu(let title, let onBack, let menuTitle, let onMenuAction):
                    tertiaryMenuHeader(title: title, onBack: onBack, menuTitle: menuTitle, onMenuAction: onMenuAction)
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
        HStack(spacing: 12) {
            Image("BeilsangIcon", bundle: .designSystem)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
            
            Image("typoLogo", bundle: .designSystem)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 20)
            
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
    
    private func primaryTitleHeader(
        title: String,
        onNotification: @escaping () -> Void,
        onSearch: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 6) {
            Text(title)
                .fontStyle(Fonts.title1Bold)
                .foregroundColor(ColorSystem.labelNormalStrong)
            
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
    
    private func secondaryWithSaveHeader(title: String, onBack: @escaping () -> Void, onSave: @escaping () -> Void, canSave: Bool) -> some View {
        HStack {
            Button(action: onBack) {
                Image("backIcon", bundle: .designSystem)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
            }
            
            Spacer()
            
            Text(title)
                .fontStyle(Fonts.heading1Bold)
                .foregroundColor(ColorSystem.labelNormalStrong)
            
            Spacer()
            
            Button("저장") {
                onSave()
            }
            .fontStyle(.body1SemiBold)
            .foregroundColor(canSave ? ColorSystem.primaryStrong : ColorSystem.labelNormalBasic)
            .disabled(!canSave)
        }
    }
    
    private func tertiaryReportHeader(title: String, onBack: @escaping () -> Void, onOption: @escaping () -> Void) -> some View {
        HStack {
            Button(action: onBack) {
                Image("backIcon", bundle: .designSystem)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
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
    
    private func tertiaryMenuHeader(title: String, onBack: @escaping () -> Void, menuTitle: String, onMenuAction: @escaping () -> Void) -> some View {
        HStack {
            Button(action: onBack) {
                Image("backIcon", bundle: .designSystem)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
            }
            
            Spacer()
            
            Text(title)
                .fontStyle(Fonts.heading1Bold)
                .foregroundColor(ColorSystem.labelNormalStrong)
            
            Spacer()
            
            Menu {
                Button(role: .destructive) {
                    onMenuAction()
                } label: {
                    Label(menuTitle, systemImage: "bell.slash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(ColorSystem.labelNormalStrong)
            }
            .buttonStyle(.plain)
        }
    }
}
