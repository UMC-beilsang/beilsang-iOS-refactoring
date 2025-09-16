//
//  ToastModifier.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 8/29/25.
//

import SwiftUI

public struct ToastModifier: ViewModifier {
    @EnvironmentObject var toastManager: ToastManager
    let bottomPadding: CGFloat
    
    public init(bottomPadding: CGFloat) {
        self.bottomPadding = bottomPadding
    }
    
    public func body(content: Content) -> some View {
        ZStack {
            content
            if let toast = toastManager.toast {
                VStack {
                    Spacer()
                    if toastManager.isVisible {
                        ToastView(iconName: toast.iconName, message: toast.message)
                            .padding(.bottom, bottomPadding)
                            .transition(.opacity)
                    }
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }
}

public extension View {
    func withToast() -> some View {
        self.modifier(ToastModifier(bottomPadding: UIScreen.main.bounds.height * 0.17))
    }
    
    func withToastLow() -> some View {
        self.modifier(ToastModifier(bottomPadding: UIScreen.main.bounds.height * 0.14))
    }
}
