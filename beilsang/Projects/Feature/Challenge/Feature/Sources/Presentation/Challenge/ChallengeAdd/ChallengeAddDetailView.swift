//
//  ChallengeAddDetailView.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 10/3/25.
//

import SwiftUI
import UIComponentsShared
import DesignSystemShared
import ModelsShared

struct ChallengeAddDetailView: View {
    @ObservedObject var viewModel: ChallengeAddViewModel
    @EnvironmentObject var toastManager: ToastManager
    @FocusState private var focusedField: ChallengeInfoField?
    
    var body: some View {
        VStack(alignment: .leading) {
            StepTitleView(title: "챌린지의 인증 방법과\n인증 사진을 입력해 주세요")
            
            Spacer(minLength: UIScreen.main.bounds.height * 0.06)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    descriptionSection
                    cautionSection
                    sampleImagesSection
                    pointSection
                }
            }
            .scrollBounceBehavior(.basedOnSize)
        }
        .padding(.horizontal, 24)
        .dismissKeyboardOnTap(focusedField: $focusedField)
        .photosPicker(
            isPresented: $viewModel.showImagePicker,
            selection: $viewModel.selectedPhotos,
            maxSelectionCount: 4,
            matching: .images
        )
        .onChange(of: viewModel.selectedPhotos) { _, newItems in
            guard !newItems.isEmpty else { return }
            viewModel.loadSampleImages(from: newItems)
        }
        .fullScreenCover(isPresented: $viewModel.showImageModal) {
            ImageModalView(
                photos: viewModel.samplePhotos,
                selectedID: $viewModel.selectedPhotoID,
                isPresented: $viewModel.showImageModal
            )
        }
    }
    
    // MARK: - Description Section
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("챌린지 세부 설명")
                .fontStyle(.heading3Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)
            
            LargeTextField(
                text: $viewModel.description,
                placeholder: "세부 설명을 입력해 주세요",
                minHeight: 120,
                maxLines: 5...10,
                minLength: 20,
                maxLength: 80,
                helperText: "세부 설명은 20~80자 이내로 입력해 주세요",
                onValidationChange: { isValid in
                    viewModel.updateDescriptionValidity(isValid)
                }
            )
        }
    }
    
    // MARK: - Caution Section
    private var cautionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("챌린지 인증 유의사항")
                .fontStyle(.heading3Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)
            
            LargeTextField(
                text: $viewModel.caution,
                placeholder: "챌린지 인증 유의사항을 적어 주세요",
                minHeight: 120,
                maxLines: 5...10,
                maxLength: 50,
                helperText: "챌린지 인증 유의사항은 50자 이내로 입력해 주세요",
                onValidationChange: { isValid in
                    viewModel.updateCautionValidity(isValid)
                }
            )
        }
    }
    
    // MARK: - Sample Images Section
    private var sampleImagesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("모범 인증 사진")
                .fontStyle(.heading3Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)
            
            VStack(alignment: .leading, spacing: 6) {
                CustomPhotoPickerView(
                    photos: $viewModel.samplePhotos,
                    maxPhotoCount: 4,
                    onAddTapped: {
                        viewModel.showSampleImagePicker()
                    },
                    onImageTapped: { id in
                        viewModel.showSampleImageModal(id: id)
                    },
                    onRemoveTapped: { id in
                        viewModel.removeSampleImage(id: id)
                    }
                )
                
                Text("모범 인증 사진은 4장을 올려 주세요")
                    .fontStyle(.detail2Regular)
                    .foregroundStyle(ColorSystem.labelNormalBasic)
            }
        }
    }
    
    // MARK: - Point Section
    private var pointSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("챌린지 최소 참여 포인트")
                .fontStyle(.heading3Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)
            
            StepperField(
                value: viewModel.minPoint,
                minValue: 100,
                maxValue: 1000,
                unitText: { _ in "참여 포인트의 단위는 100 단위로 올라 갑니다" },
                onIncrease: {
                    viewModel.increasePoint()
                },
                onDecrease: {
                    viewModel.decreasePoint()
                }
            )
        }
    }
}
