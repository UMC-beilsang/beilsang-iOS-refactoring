//
//  CustomTabBar.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 11/27/25.
//

import SwiftUI
import DesignSystemShared

public struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    public init(selectedTab: Binding<Int>) {
        self._selectedTab = selectedTab
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            TabBarItem(
                icon: "homeIcon",
                selectedIcon: "homeIconSelected",
                title: "홈",
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
            }
            
            TabBarItem(
                icon: "discoverIcon",
                selectedIcon: "discoverIconSelected",
                title: "발견",
                isSelected: selectedTab == 1
            ) {
                selectedTab = 1
            }
            
            TabBarItem(
                icon: "learnMoreIcon",
                selectedIcon: "learnMoreIconSelected",
                title: "더 알아보기",
                isSelected: selectedTab == 2
            ) {
                selectedTab = 2
            }
            
            TabBarItem(
                icon: "myPageIcon",
                selectedIcon: "myPageIconSelected",
                title: "마이페이지",
                isSelected: selectedTab == 3
            ) {
                selectedTab = 3
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 34)
        .background(
            RoundedCorner(radius: 24, corners: [.topLeft, .topRight])
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.16), radius: 7, x: 0, y: 0)
        )
    }
}

// MARK: - Tab Bar Item
struct TabBarItem: View {
    let icon: String
    let selectedIcon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(isSelected ? selectedIcon : icon, bundle: .designSystem)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                
                Text(title)
                    .fontStyle(.detail1Medium)
                    .foregroundColor(ColorSystem.labelNormalNormal)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Rounded Corner Shape
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview
#if DEBUG
struct CustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            CustomTabBar(selectedTab: .constant(0))
        }
        .background(Color.gray.opacity(0.1))
        .ignoresSafeArea()
    }
}
#endif

