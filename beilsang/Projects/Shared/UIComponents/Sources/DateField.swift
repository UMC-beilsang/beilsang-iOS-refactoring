//
//  DateField.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 10/3/25.
//

import SwiftUI
import DesignSystemShared
import UtilityShared

public struct DateField: View {
    public var placeholder: String
    @Binding public var date: Date?
    
    @State private var showPicker = false
    
    public init(
        placeholder: String,
        date: Binding<Date?>
    ) {
        self.placeholder = placeholder
        self._date = date
    }
    
    public var body: some View {
        Button {
            showPicker.toggle()
        } label: {
            HStack {
                Text(formattedDate)
                    .fontStyle(.body2Medium)
                    .foregroundStyle(
                        date == nil
                            ? ColorSystem.labelNormalBasic
                            : ColorSystem.labelNormalStrong
                    )
                
                Spacer()
                
                Image("calenderIcon", bundle: .designSystem)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
            .frame(height: 48)
            .padding(.horizontal, 12)
            .background(ColorSystem.labelNormalDisable)
            .cornerRadius(8)
        }
        .sheet(isPresented: $showPicker) {
            DatePickerSheet(
                date: Binding(
                    get: { date ?? Date() },
                    set: { _ in }
                ),
                showPicker: $showPicker,
                onConfirm: { selectedDate in
                    date = selectedDate
                }
            )
            .presentationDetents([.medium])
        }
    }
    
    private var formattedDate: String {
        guard let date = date else {
            return placeholder
        }
        return DateFormatter.koreanDateWithWeekday.string(from: date)
    }
}

public struct DatePickerSheet: View {
    @Binding var date: Date
    @Binding var showPicker: Bool
    let onConfirm: (Date) -> Void
    
    @State private var selectedDate: Date
    
    public init(
        date: Binding<Date>,
        showPicker: Binding<Bool>,
        onConfirm: @escaping (Date) -> Void
    ) {
        self._date = date
        self._showPicker = showPicker
        self.onConfirm = onConfirm
        self._selectedDate = State(initialValue: date.wrappedValue)
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            DatePicker(
                "",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .padding()
            
            Button {
                onConfirm(selectedDate)
                showPicker = false
            } label: {
                Text("확인")
                    .fontStyle(.heading2Bold)
                    .foregroundStyle(ColorSystem.labelWhite)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(ColorSystem.primaryStrong)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
}
