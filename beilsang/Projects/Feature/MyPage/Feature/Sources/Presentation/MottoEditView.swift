//
//  MottoEditView.swift
//  MyPageFeature
//
//  Created by Seyoung Park on 11/26/25.
//

import SwiftUI
import UIComponentsShared
import ModelsShared
import DesignSystemShared

struct MottoEditView: View {
    @Binding var selectedMotto: Motto?
    @Environment(\.dismiss) var dismiss
    var onSave: (() -> Void)?
    
    let availableMottos = Motto.allCases
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 헤더
            Header(type: .secondary(
                title: "나의 다짐",
                onBack: { dismiss() }
            ))
            
            VStack(alignment: .leading, spacing: 0) {
                // 제목
                StepTitleView(title: "비일상을 통해 이루고 싶은\n다짐을 선택해 주세요!")
                    .padding(.horizontal, 24)
                    .padding(.top, 32)
                
                Spacer().frame(height: 40)
                
                // 다짐 리스트
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(availableMottos) { motto in
                            SelectableItemView(
                                title: motto.title,
                                iconName: motto.iconName,
                                isSelected: selectedMotto == motto,
                                hasAnySelection: selectedMotto != nil,
                                onTap: {
                                    if selectedMotto == motto {
                                        selectedMotto = nil
                                    } else {
                                        selectedMotto = motto
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 120)
                }
                
                Spacer()
            }
            
            // 하단 버튼
            VStack {
                NextStepButton(
                    title: "다음으로",
                    isEnabled: selectedMotto != nil,
                    onTap: {
                        onSave?()
                        dismiss()
                    }
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 34)
            }
            .background(ColorSystem.backgroundNormalNormal)
        }
        .background(ColorSystem.backgroundNormalNormal)
        .toolbar(.hidden, for: .navigationBar)
    }
}
