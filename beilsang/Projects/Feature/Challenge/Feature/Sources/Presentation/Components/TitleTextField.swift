//
//  TitleTextField.swift
//  UIComponentsShared
//

import SwiftUI
import DesignSystemShared
import ModelsShared
import UIComponentsShared

public struct TitleTextField: View {
    @Binding var text: String
    @Binding var state: TextFieldState
    @FocusState private var isFocused: Bool
    @State private var debounceTask: Task<Void, Never>?
    
    var onClearTapped: (() -> Void)?
    
    public init(
        text: Binding<String>,
        state: Binding<TextFieldState>,
        onClearTapped: (() -> Void)? = nil
    ) {
        self._text = text
        self._state = state
        self.onClearTapped = onClearTapped
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text("챌린지 제목을 입력해 주세요")
                            .foregroundColor(ColorSystem.labelNormalBasic)
                            .fontStyle(Fonts.body2Medium)
                            .padding(.leading, 12)
                    }
                    
                    HStack(spacing: 8) {
                        TextField("", text: $text)
                            .focused($isFocused)
                            .fontStyle(Fonts.body2Medium)
                            .foregroundStyle(state.textColor)
                            .onChange(of: text) { _ in
                                handleTyping()
                            }
                            .onChange(of: isFocused) { newValue in
                                handleFocusChange(isFocused: newValue)
                            }
                        
                        if (state == .typing || state == .filled) && !text.isEmpty {
                            Button {
                                text = ""
                                onClearTapped?()
                            } label: {
                                Image("clearIcon", bundle: .designSystem)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                            }
                        }
                    }
                    .frame(height: 48)
                    .padding(.horizontal, 12)
                }
                .background(state.backgroundColor)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(state.borderColor, lineWidth: 1.25)
                )
            }
            
            Text("1~30자 이내로 입력해 주세요")
                .fontStyle(Fonts.detail2Regular)
                .foregroundColor(state.alertTextColor)
        }
    }
    
    // MARK: - 내부 로직
    private func handleTyping() {
        debounceTask?.cancel()
        if text.isEmpty {
            state = isFocused ? .focused : .idle
            return
        }
        
        if isFocused {
            state = .typing
            debounceTask = Task {
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                if !Task.isCancelled {
                    submit()
                }
            }
        }
    }
    
    private func handleFocusChange(isFocused: Bool) {
        if !isFocused { submit() }
        else if text.isEmpty { state = .focused }
    }
    
    private func submit() {
        debounceTask?.cancel()
        if text.isEmpty {
            state = .idle
        } else if (1...30).contains(text.count) {
            state = .valid
        } else {
            state = .invalidFormat
        }
    }
}
