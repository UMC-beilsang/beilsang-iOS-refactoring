//
//  NicknameTextField.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 8/30/25.
//

import SwiftUI
import DesignSystemShared
import ModelsShared

public struct NicknameTextField: View {
    @Binding var text: String
    var state: NicknameState
    var onCheckTapped: (() -> Void)?
    var onClearTapped: (() -> Void)?
    @FocusState private var isFocused: Bool
    
    public init(
        text: Binding<String>,
        state: NicknameState,
        onCheckTapped: (() -> Void)? = nil,
        onClearTapped: (() -> Void)? = nil
    ) {
        self._text = text
        self.state = state
        self.onCheckTapped = onCheckTapped
        self.onClearTapped = onClearTapped
    }
    
    
    public var body: some View {
        let style = state.style
        
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text("닉네임을 입력해 주세요")
                            .foregroundColor(ColorSystem.labelNormalBasic)
                            .fontStyle(Fonts.body2Medium)
                            .padding(.leading, 12)
                    }
                    
                    HStack(alignment: .center, spacing: 8) {
                        TextField("", text: $text)
                            .fontStyle(Fonts.body2Medium)
                            .foregroundStyle(style.text)
                            .focused($isFocused)
                        
                        if (state == .typing || state == .filled) && !text.isEmpty {
                            Button(action: {
                                text = ""
                                onClearTapped?()
                            }) {
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
                .background(style.background)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(borderColor, lineWidth: 1.25)
                )
                
                if let onCheckTapped = onCheckTapped {
                    Button(action: onCheckTapped) {
                        Text(buttonTitle)
                            .fontStyle(Fonts.body1SemiBold)
                            .foregroundColor(style.buttonText)
                            .frame(height: 48)
                            .padding(.horizontal, 14)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(style.buttonBackground)
                    )
                }
            }
            
            // 상태 메시지
            switch state {
            case .valid:
                Text("사용 가능한 닉네임입니다")
                    .fontStyle(Fonts.detail2Regular)
                    .foregroundColor(style.alretText)
                
            case .invalidDuplicate:
                Text("이미 존재하는 닉네임입니다")
                    .fontStyle(Fonts.detail2Regular)
                    .foregroundColor(style.alretText)
                
            case .idle, .focused, .typing, .filled, .checking, .invalidFormat:
                Text("2~15자 이내로 특수문자 없이 입력해 주세요")
                    .fontStyle(Fonts.detail2Regular)
                    .foregroundColor(style.alretText)
            }
        }
    }
    
    private var buttonTitle: String {
        switch state {
        case .valid, .invalidFormat, .invalidDuplicate:
            return "확인 완료"
        default:
            return "중복 확인"
        }
    }
    
    private var borderColor: Color {
        switch state {
        case .valid, .invalidFormat, .invalidDuplicate:
            return state.style.border
        case .idle, .focused, .typing, .filled, .checking:
            return (state == .focused || state == .typing || isFocused) ? ColorSystem.primaryStrong : state.style.border
        }
    }
    
    /// 외부에서 포커스를 해제할 수 있도록
    public func dismissFocus() {
        isFocused = false
    }
}
