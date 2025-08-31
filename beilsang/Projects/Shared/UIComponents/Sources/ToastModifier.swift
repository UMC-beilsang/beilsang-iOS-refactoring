//
//  ToastContainer.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 8/29/25.
//

import SwiftUI

public struct ToastModifier: ViewModifier {
    @EnvironmentObject var toastManager: ToastManager
    
    public func body(content: Content) -> some View {
        ZStack {
            content
            if let toast = toastManager.toast {
                VStack {
                    Spacer()
                    if toastManager.isVisible {  
                        ToastView(iconName: toast.iconName, message: toast.message)
                            .padding(.bottom, UIScreen.main.bounds.height * 0.17)
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
        self.modifier(ToastModifier())
    }
}
