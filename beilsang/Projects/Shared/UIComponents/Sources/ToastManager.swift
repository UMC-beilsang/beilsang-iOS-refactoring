//
//  ToastManager.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 8/29/25.
//

import SwiftUI

public final class ToastManager: ObservableObject {
    @Published public var toast: ToastMessage?
    @Published public var isVisible: Bool = false
    
    public init() {} 

    public func show(
        iconName: String? = nil,
        message: String,
        duration: TimeInterval = 2
    ) {
        let toast = ToastMessage(iconName: iconName, message: message)
        self.toast = toast
        withAnimation(.easeInOut(duration: 0.3)) {
            self.isVisible = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.isVisible = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if self.toast?.id == toast.id {
                    self.toast = nil
                }
            }
        }
    }
}

public struct ToastMessage: Identifiable, Equatable {
    public let id = UUID()
    public let iconName: String?
    public let message: String
}
