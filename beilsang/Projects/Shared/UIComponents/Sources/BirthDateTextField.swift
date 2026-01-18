//
//  BirthDateTextField.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 11/26/25.
//

import SwiftUI
import DesignSystemShared

public struct BirthDateTextField: View {
    @Binding var birthDate: Date?
    @State private var rawInput: String = ""
    @FocusState private var isFocused: Bool
    let placeholder: String
    
    public init(
        birthDate: Binding<Date?>,
        placeholder: String = "생년월일 8자리를 입력해 주세요"
    ) {
        self._birthDate = birthDate
        self.placeholder = placeholder
    }
    
    public var body: some View {
        HStack {
            ZStack(alignment: .leading) {
                // Placeholder
                if rawInput.isEmpty {
                    Text(placeholder)
                        .fontStyle(Fonts.body2Medium)
                        .foregroundStyle(ColorSystem.labelNormalBasic)
                }
                
                // TextField
                TextField("", text: Binding(
                    get: { displayText },
                    set: { handleInput($0) }
                ))
                .keyboardType(.numberPad)
                .fontStyle(Fonts.body2Medium)
                .foregroundStyle(ColorSystem.labelNormalStrong)
                .focused($isFocused)
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 48)
        .background(ColorSystem.labelNormalDisable)
        .cornerRadius(8)
        .onAppear {
            // 초기 birthDate가 있으면 rawInput 설정
            if let date = birthDate {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyyMMdd"
                rawInput = formatter.string(from: date)
            }
        }
        .onChange(of: birthDate) { _, newDate in
            // 외부에서 birthDate가 변경되면 rawInput 업데이트
            if let date = newDate {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyyMMdd"
                let newRaw = formatter.string(from: date)
                if rawInput != newRaw {
                    rawInput = newRaw
                }
            }
        }
    }
    
    private var displayText: String {
        // rawInput이 비어있으면 빈 문자열 (placeholder가 보임)
        guard !rawInput.isEmpty else { return "" }
        
        // 포맷팅된 텍스트 반환
        return formatBirthDate(rawInput)
    }
    
    private func formatBirthDate(_ input: String) -> String {
        let cleaned = input.filter { $0.isNumber }
        
        guard !cleaned.isEmpty else { return "" }
        
        var result = ""
        
        for (index, char) in cleaned.enumerated() {
            if index == 4 {
                result += "년 "
            } else if index == 6 {
                result += "월 "
            }
            result += String(char)
        }
        
        // 완성된 경우 "일" 추가
        if cleaned.count == 8 {
            result += "일"
        }
        
        return result
    }
    
    private func handleInput(_ newValue: String) {
        // 숫자만 추출 (포맷팅 문자 제거)
        let cleaned = newValue.filter { $0.isNumber }
        
        // 8자리 제한 적용
        let limited = String(cleaned.prefix(8))
        
        // 입력값 업데이트
        rawInput = limited
        
        // 8자리가 완성되면 유효한 날짜인지 확인
        if limited.count == 8 {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            formatter.isLenient = false // 엄격한 날짜 검증
            
            if let date = formatter.date(from: limited) {
                // 유효한 날짜 범위 확인 (1900년 ~ 현재 날짜 포함)
                let calendar = Calendar.current
                let year = calendar.component(.year, from: date)
                let currentYear = calendar.component(.year, from: Date())
                let today = calendar.startOfDay(for: Date())
                let inputDate = calendar.startOfDay(for: date)
                
                // 1900년 이상이고, 현재 날짜를 포함한 이전 날짜만 허용
                if year >= 1900 && year <= currentYear && inputDate <= today {
                    birthDate = date
                } else {
                    // 유효하지 않은 날짜 범위면 birthDate를 nil로 설정
                    birthDate = nil
                }
            } else {
                // 유효하지 않은 날짜 형식(예: 20251301, 20240230)이면 birthDate를 nil로 설정
                birthDate = nil
            }
        } else {
            // 8자리 미만이면 birthDate를 nil로 설정
            birthDate = nil
        }
    }
}
