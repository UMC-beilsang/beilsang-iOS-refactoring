//
//  CategoryGridView.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 10/31/25.
//

import SwiftUI
import ModelsShared
import DesignSystemShared

public struct CategoryGridView: View {
    public enum Layout {
        case twoRow
        case singleRow
    }

    private let layout: Layout
    private let selectedKeyword: Keyword?
    private let onCategoryTapped: (Keyword) -> Void

    // MARK: - Init
    public init(
        layout: Layout,
        selectedKeyword: Keyword? = nil,
        onCategoryTapped: @escaping (Keyword) -> Void
    ) {
        self.layout = layout
        self.selectedKeyword = selectedKeyword
        self.onCategoryTapped = onCategoryTapped
    }

    public var body: some View {
        switch layout {
        case .twoRow:
            twoRowView
        case .singleRow:
            singleRowView
        }
    }

    // MARK: - 홈(2단)
    private var twoRowView: some View {
        let rows = [
            GridItem(.fixed(80), spacing: 8),
            GridItem(.fixed(80), spacing: 8)
        ]

        return ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: rows, spacing: 8) {
                ForEach(Keyword.allCases, id: \.self) { keyword in
                    categoryButton(keyword)
                }
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - 디스커버(1단)
    private var singleRowView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Keyword.allCases, id: \.self) { keyword in
                    categoryButton(keyword)
                }
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Category Cell
    private func categoryButton(_ keyword: Keyword) -> some View {
        let isSelected = selectedKeyword == keyword

        return Button {
            onCategoryTapped(keyword)
        } label: {
            VStack(spacing: 8) {
                Image(keyword.iconName, bundle: .designSystem)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .foregroundColor(isSelected ? ColorSystem.primaryStrong : ColorSystem.labelNormalStrong)

                Text(keyword.title)
                    .fontStyle(Fonts.detail1Medium)
                    .foregroundColor(isSelected ? ColorSystem.primaryStrong : ColorSystem.labelNormalNormal)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 80, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? ColorSystem.labelWhite : ColorSystem.labelNormalDisable)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? ColorSystem.primaryStrong : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}
