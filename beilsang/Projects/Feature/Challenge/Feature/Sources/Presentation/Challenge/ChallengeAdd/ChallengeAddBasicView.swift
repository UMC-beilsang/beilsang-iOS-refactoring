//
//  ChallengeAddBasicView.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 10/3/25.
//

import SwiftUI
import UIComponentsShared
import DesignSystemShared
import ModelsShared

struct ChallengeAddBasicView: View {
    @ObservedObject var viewModel: ChallengeAddViewModel
    @EnvironmentObject var toastManager: ToastManager
    @FocusState private var isTitleFocused: Bool
    @FocusState private var focusedField: ChallengeInfoField?
    
    var body: some View {
        VStack(alignment: .leading) {
            StepTitleView(title: "새로 만드는 챌린지의\n기본 정보를 입력해 주세요!")
            
            Spacer(minLength: UIScreen.main.bounds.height * 0.06)
            
            VStack(alignment: .leading, spacing: 32) {
                representImageView
                titleView
                categoryView
                startDateView
                periodView
                practiceCountView
            }
        }
        .padding(.horizontal, 24)
        .photosPicker(
            isPresented: $viewModel.showImagePicker,
            selection: $viewModel.selectedPhotos,
            maxSelectionCount: 5,
            matching: .images
        )
        .onChange(of: viewModel.selectedPhotos) { _, newItems in
            guard !newItems.isEmpty else { return }
            viewModel.loadRepresentativeImages(from: newItems)
        }
        .onChange(of: viewModel.shouldLoseFocus) { newValue in
            if newValue {
                isTitleFocused = false
                viewModel.shouldLoseFocus = false
            }
        }
        .fullScreenCover(isPresented: $viewModel.showImageModal) {
            ImageModalView(
                photos: viewModel.representativePhotos,
                selectedID: $viewModel.selectedPhotoID,
                isPresented: $viewModel.showImageModal
            )
        }
        .dismissKeyboardOnTap(focusedField: $focusedField)
    }
    
    private var representImageView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("챌린지 대표 이미지")
                .fontStyle(.heading3Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)
            
            CustomPhotoPickerView(
                photos: $viewModel.representativePhotos,
                maxPhotoCount: 5,
                onAddTapped: { viewModel.showRepresentativeImagePicker() },
                onImageTapped: { id in viewModel.showRepresentativeImageModal(id: id) },
                onRemoveTapped: { id in
                    viewModel.removeRepresentativeImage(id: id)
                    toastManager.show(message: "대표 이미지를 삭제했어요.")
                }
            )
        }
    }
    
    private var titleView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("챌린지 제목")
                .fontStyle(.heading3Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)
            
            TitleTextField(
                text: $viewModel.title,
                state: $viewModel.titleState,
                onClearTapped: { viewModel.title = "" }
            )
        }
    }
    
    private var categoryView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("챌린지 카테고리")
                .fontStyle(.heading3Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)
            
            DropdownField(
                selected: $viewModel.category,
                placeholder: "카테고리를 선택해 주세요",
                options: Keyword.allCases,
                optionTitle: { $0.title }
            )
        }
    }
    
    private var startDateView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("챌린지 기간")
                .fontStyle(.heading3Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)
            
            DateField(placeholder: "챌린지 시작일을 선택해 주세요", date: $viewModel.startDate)
        }
    }
    
    private var periodView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("챌린지 실천기간")
                .fontStyle(.heading3Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)
            
            DropdownField(
                selected: $viewModel.period,
                placeholder: "챌린지 실천기간을 선택해 주세요",
                options: ChallengePeriod.dropdownOptions,
                optionTitle: { $0.title }
            )
        }
    }
    
    private var practiceCountView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("챌린지 실천 횟수")
                .fontStyle(.heading3Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)
            
            StepperField(
                value: viewModel.practiceCount,
                minValue: 1,
                maxValue: viewModel.period?.maxCount(startDate: viewModel.startDate) ?? 1,
                unitText: { value in
                    let periodTitle = viewModel.period?.title ?? "기간"
                    return "\(value)회 설정 시, \(periodTitle) 중 \(value)일을 실천 후 인증해야 합니다"
                },
                onIncrease: { viewModel.increasePracticeCount() },
                onDecrease: { viewModel.decreasePracticeCount() }
            )
        }
    }
}
