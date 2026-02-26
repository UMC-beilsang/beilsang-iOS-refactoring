//
//  FilterBottomSheet.swift
//  ChallengeFeature
//
//  Created by Seyoung
//

import SwiftUI
import DesignSystemShared
import UIComponentsShared
import ModelsShared

struct FilterBottomSheet: View {
    let selectedFilter: ChallengeFilter
    let onFilterSelected: (ChallengeFilter) -> Void
    
    @State private var tempSelectedFilter: ChallengeFilter
    
    init(selectedFilter: ChallengeFilter, onFilterSelected: @escaping (ChallengeFilter) -> Void) {
        self.selectedFilter = selectedFilter
        self.onFilterSelected = onFilterSelected
        _tempSelectedFilter = State(initialValue: selectedFilter)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                // 제목
                Text("필터")
                    .fontStyle(.heading1Bold)
                    .foregroundStyle(ColorSystem.labelNormalStrong)
                    .padding(.horizontal, 24)
                    .padding(.top, 32)
                    .padding(.bottom, 16)
                
                // 필터 옵션들
                VStack(spacing: 20) {
                    ForEach(ChallengeFilter.allCases, id: \.self) { filter in
                        FilterOption(
                            title: filter.rawValue,
                            description: filter.description,
                            isSelected: tempSelectedFilter == filter,
                            onTap: {
                                tempSelectedFilter = filter
                            }
                        )
                    }
                }
                .padding(.vertical, 20)
                
                Spacer()
            }
            .background(ColorSystem.backgroundNormalNormal)
            
            // 하단 버튼
            ZStack {
                BottomOverlayGradient()
                    .frame(height: UIScreen.main.bounds.height * 0.17)
                    .allowsHitTesting(false)
                
                NextStepButton(
                    title: "필터 적용하기",
                    isEnabled: true,
                    onTap: {
                        onFilterSelected(tempSelectedFilter)
                    }
                )
                .padding(.horizontal, 24)
                .padding(.bottom, UIScreen.main.bounds.height * 0.05)
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

struct FilterOption: View {
    let title: String
    let description: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                
                // 라디오 버튼
                Image(isSelected ? "radioSelectedIcon" : "radioUnselectedIcon", bundle: .designSystem)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                
                
                HStack(spacing: 20) {
                    
                    Text(title)
                        .fontStyle(.body2SemiBold)
                        .foregroundStyle(ColorSystem.labelNormalNormal)
                    
                    Text(description)
                        .fontStyle(.detail1Medium)
                        .foregroundStyle(ColorSystem.labelNormalBasic)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .buttonStyle(.plain)
    }
}
