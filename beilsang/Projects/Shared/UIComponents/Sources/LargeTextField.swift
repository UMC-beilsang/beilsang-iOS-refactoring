//
//  LargeTextField.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 10/3/25.
//

import SwiftUI
import DesignSystemShared
import ModelsShared

public struct LargeTextField: View {
    @Binding var text: String
    let placeholder: String
    let minHeight: CGFloat
    let maxLines: ClosedRange<Int>
    let minLength: Int?
    let maxLength: Int?
    let helperText: String?
    let onValidationChange: ((Bool) -> Void)?
    
    @State private var state: TextFieldState = .idle
    @FocusState private var isFocused: Bool
    
    public init(
        text: Binding<String>,
        placeholder: String,
        minHeight: CGFloat = 120,
        maxLines: ClosedRange<Int> = 5...10,
        minLength: Int? = nil,
        maxLength: Int? = nil,
        helperText: String? = nil,
        onValidationChange: ((Bool) -> Void)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.minHeight = minHeight
        self.maxLines = maxLines
        self.minLength = minLength
        self.maxLength = maxLength
        self.helperText = helperText
        self.onValidationChange = onValidationChange
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            textFieldContainer
            
            if let helperText = helperText {
                Text(helperText)
                    .fontStyle(.detail2Regular)
                    .foregroundStyle(state.alertTextColor)
            }
        }
    }
    
    // MARK: - View Components
    private var textFieldContainer: some View {
        ZStack(alignment: .topLeading) {
            TextField("", text: $text, axis: .vertical)
                .fontStyle(.body2Medium)
                .focused($isFocused)
                .onChange(of: isFocused) { _, focused in
                    handleFocusChange(focused: focused)
                }
                .onChange(of: text) { oldValue, newValue in
                    handleTextChange(oldValue: oldValue, newValue: newValue)
                }
                .padding(12)
                .frame(minHeight: minHeight, alignment: .topLeading)
                .lineLimit(maxLines)
                .foregroundStyle(state.textColor)
            
            if text.isEmpty {
                placeholderView
            }
        }
        .background(state.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(state.borderColor, lineWidth: 1)
        )
    }
    
    private var placeholderView: some View {
        Text(placeholder)
            .fontStyle(.body2Medium)
            .foregroundStyle(ColorSystem.labelNormalBasic)
            .padding(12)
            .allowsHitTesting(false)
    }
    
    // MARK: - State Management
    private func handleFocusChange(focused: Bool) {
        if text.isEmpty {
            state = focused ? .focused : .idle
            return
        }
        
        if focused {
            state = .typing
        } else {
            validateAndUpdateState()
        }
    }
    
    private func handleTextChange(oldValue: String, newValue: String) {
        let wasValid = isCurrentlyValid(text: oldValue)
        
        if newValue.isEmpty {
            state = isFocused ? .focused : .idle
        } else {
            state = isFocused ? .typing : .filled
        }
        
        let nowValid = isCurrentlyValid(text: newValue)
        if wasValid != nowValid {
            onValidationChange?(nowValid)
        }
    }
    
    private func validateAndUpdateState() {
        if !isCurrentlyValid(text: text) {
            state = .invalidFormat
            onValidationChange?(false)
        } else {
            state = .valid
            onValidationChange?(true)
        }
    }
    
    private func isCurrentlyValid(text: String) -> Bool {
        guard !text.isEmpty else { return false }
        
        if let minLength, text.count < minLength {
            return false
        }
        
        if let maxLength, text.count > maxLength {
            return false
        }
        
        return true
    }
}
