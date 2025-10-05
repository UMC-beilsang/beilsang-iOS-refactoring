//
//  ChallengeCertView.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/17/25.
//

import SwiftUI
import UIComponentsShared
import ModelsShared
import DesignSystemShared
import UtilityShared
import ChallengeDomain
import PhotosUI

struct ChallengeCertView: View {
    @StateObject private var viewModel: ChallengeCertViewModel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var toastManager: ToastManager
    @FocusState private var focusedField: ChallengeInfoField?
    
    init(challengeId: Int, repository: ChallengeRepositoryProtocol) {
        self._viewModel = StateObject(
            wrappedValue: ChallengeCertViewModel(
                challengeId: challengeId,
                repository: repository
            )
        )
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                headerView
                contentScrollView
            }
            
            submitButton
        }
        .ignoresSafeArea(edges: .bottom)
        .withToast()
        .dismissKeyboardOnTap(focusedField: $focusedField)
        .sheet(isPresented: $viewModel.showGuideModal) {
            GuideModalView(
                certImages: viewModel.certImages,
                onConfirm: { viewModel.dismissGuideModal() }
            )
            .presentationDetents([.height(UIScreen.main.bounds.height * 0.44)])
            .presentationDragIndicator(.visible)
        }
        .photosPicker(
            isPresented: $viewModel.showImagePicker,
            selection: $viewModel.selectedPhotos,
            maxSelectionCount: 5,
            matching: .images
        )
        .onChange(of: viewModel.selectedPhotos) { _, newItems in
            guard !newItems.isEmpty else { return }
            viewModel.loadImages(from: newItems)
        }
        .fullScreenCover(isPresented: $viewModel.showImageModal) {
            ImageModalView(
                photos: viewModel.selectedPhotoStates,
                selectedID: $viewModel.selectedPhotoID,
                isPresented: $viewModel.showImageModal
            )
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        Header(type: .secondary(
            title: "챌린지 인증하기",
            onBack: { dismiss() }
        ))
    }
    
    // MARK: - Content
    private var contentScrollView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                mainContentSection
                noticeSection
            }
            .padding(.bottom, 40)
        }
        .background(ColorSystem.labelNormalDisable)
        .scrollBounceBehavior(.basedOnSize)
    }
    
    private var mainContentSection: some View {
        VStack(alignment: .leading, spacing: 32) {
            certificationPhotosSection
            reviewSection
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 20)
        .background(ColorSystem.labelWhite)
    }
    
    // MARK: - Certification Photos
    private var certificationPhotosSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("챌린지 인증 사진")
                .fontStyle(.heading3Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)
            
            VStack(alignment: .leading, spacing: 6) {
                CustomPhotoPickerView(
                    photos: $viewModel.selectedPhotoStates,
                    maxPhotoCount: 5,
                    onAddTapped: {
                        viewModel.showImageSelector()
                    },
                    onImageTapped: { id in
                        viewModel.showImageModal(id: id)
                    },
                    onRemoveTapped: { id in
                        viewModel.removeImage(id: id)
                    }
                )
                
                Text("챌린지 인증 유의사항을 확인해서 올바른 이미지를 올려 주세요")
                    .fontStyle(.detail2Regular)
                    .foregroundStyle(ColorSystem.labelNormalBasic)
            }
        }
    }
    
    // MARK: - Review Section
    private var reviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("챌린지 후기")
                .fontStyle(.heading3Bold)
                .foregroundStyle(
                    viewModel.reviewText.count > 200
                    ? ColorSystem.semanticNegativeHeavy
                    : ColorSystem.labelNormalStrong
                )
            
            LargeTextField(
                text: $viewModel.reviewText,
                placeholder: "챌린지 후기를 입력해 주세요",
                minHeight: 120,
                maxLines: 5...10,
                minLength: 20,
                maxLength: 200,
                helperText: "후기는 20~200자 이내로 입력해 주세요",
                onValidationChange: { isValid in
                    viewModel.updateReviewValidity(isValid)
                }
            )
        }
    }
    
    // MARK: - Notice Section
    private var noticeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("인증글 작성 시 유의사항")
                .fontStyle(.body2SemiBold)
                .foregroundStyle(ColorSystem.labelNormalBasic)
            
            VStack(alignment: .leading, spacing: 4) {
                noticeItem("1. 욕설, 챌린지와 관련 없는 내용은 통보 없이 삭제됩니다.")
                noticeItem("2. 인증 유의사항에 따르지 않은 사진을 업로드하면 인증 실패로 간주됩니다.")
                noticeItem("3. 동일 이미지를 중복 사용 시 인증 실패로 간주됩니다.")
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 24)
    }
    
    private func noticeItem(_ text: String) -> some View {
        Text(text)
            .fontStyle(.detail1Medium)
            .foregroundStyle(ColorSystem.labelNormalBasic)
    }
    
    // MARK: - Submit Button
    private var submitButton: some View {
        Button {
            handleSubmit()
        } label: {
            Text("챌린지 인증하기")
                .fontStyle(.heading2Bold)
                .foregroundStyle(
                    viewModel.canSubmit
                    ? ColorSystem.labelWhite
                    : ColorSystem.labelNormalBasic
                )
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(
                    viewModel.canSubmit
                    ? ColorSystem.primaryStrong
                    : ColorSystem.labelNormalAlternative
                )
                .cornerRadius(20)
        }
        .disabled(!viewModel.canSubmit)
        .padding(.horizontal, 24)
        .padding(.bottom, UIScreen.main.bounds.height * 0.08)
        .background(gradientBackground)
    }
    
    private var gradientBackground: some View {
        LinearGradient(
            colors: [
                ColorSystem.labelWhite.opacity(0),
                ColorSystem.labelWhite
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 120)
        .allowsHitTesting(false)
    }
    
    // MARK: - Actions
    private func handleSubmit() {
        if let message = viewModel.getDetailedValidationMessage() {
            toastManager.show(iconName: "toastWarningIcon", message: message)
            return
        }
        
        Task {
            let success = await viewModel.submitCertification()
            if success {
                toastManager.show(
                    iconName: "toastCheckIcon",
                    message: "챌린지 인증이 완료되었습니다"
                )
                dismiss()
            } else {
                toastManager.show(
                    iconName: "toastWarningIcon",
                    message: "인증 처리 중 오류가 발생했습니다"
                )
            }
        }
    }
}

// MARK: - Guide Modal
struct GuideModalView: View {
    let certImages: [String]
    let onConfirm: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                Text("챌린지 인증 유의사항")
                    .fontStyle(.heading1Bold)
                    .foregroundStyle(ColorSystem.labelNormalStrong)
                    .padding(.top, 32)
                    .padding(.bottom, 16)
                
                GuideContentView(certImages: certImages)
                
                Spacer()
                
                Button {
                    onConfirm()
                } label: {
                    Text("유의사항을 확인했어요")
                        .fontStyle(.heading2Bold)
                        .foregroundStyle(ColorSystem.labelWhite)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(ColorSystem.primaryStrong)
                        .cornerRadius(16)
                }
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 24)
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Preview
#Preview {
    let _ = FontRegister.registerFonts()
    
    return ChallengeCertView(
        challengeId: 1,
        repository: MockChallengeRepository()
    )
    .environmentObject(ToastManager())
}
