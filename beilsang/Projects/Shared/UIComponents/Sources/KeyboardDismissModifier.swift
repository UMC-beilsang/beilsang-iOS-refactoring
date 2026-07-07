//
//  KeyboardDismissModifier.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 8/30/25.
//

import SwiftUI

public enum KeyboardDismiss {
    public static func perform() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

// 배경을 탭하면 키보드가 내려가도록 해주는 Modifier
public struct KeyboardDismissWrapper<Field: Hashable>: ViewModifier {
    var focusedField: FocusState<Field?>.Binding
    
    public func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField.wrappedValue = nil
                KeyboardDismiss.perform()
            }
    }
}

extension View {
    public func dismissKeyboardOnTap<Field: Hashable>(
        focusedField: FocusState<Field?>.Binding
    ) -> some View {
        modifier(KeyboardDismissWrapper(focusedField: focusedField))
    }

    public func dismissKeyboard() {
        KeyboardDismiss.perform()
    }
}
