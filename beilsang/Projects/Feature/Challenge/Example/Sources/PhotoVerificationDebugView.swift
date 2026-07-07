//
//  PhotoVerificationDebugView.swift
//  ChallengeFeatureExample
//

import SwiftUI
import PhotosUI
import ChallengeFeature
import DesignSystemShared
import UIComponentsShared

/// 실제 Claude API 호출 후 앱과 동일한 PhotoVerificationSheet 표시
struct PhotoVerificationDebugView: View {
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isVerifying = false
    @State private var verificationResult: PhotoVerificationResult?
    @State private var verificationFailed = false
    @State private var showVerificationSheet = false
    @State private var errorMessage: String?

    private let service = PhotoVerificationService.fromBundle()
    private let sampleContext = ChallengeVerificationContext(
        title: "매일 30분 걷기",
        description: "하루 30분 이상 걷는 모습을 인증해 주세요.",
        category: "운동",
        notes: [
            "실외/실내에서 걷거나 조깅하는 모습",
            "운동 앱 캡처도 가능"
        ]
    )

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                apiKeyStatus

                VStack(alignment: .leading, spacing: 8) {
                    Text("테스트 챌린지")
                        .fontStyle(.heading3Bold)
                    Text(sampleContext.title)
                        .fontStyle(.body1SemiBold)
                    Text(sampleContext.description)
                        .fontStyle(.body2Medium)
                        .foregroundStyle(ColorSystem.labelNormalBasic)
                }

                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Label("사진 선택", systemImage: "photo.on.rectangle")
                        .fontStyle(.body1SemiBold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(ColorSystem.labelNormalDisable)
                        .cornerRadius(12)
                }
                .onChange(of: selectedPhoto) { _, newItem in
                    Task {
                        guard let data = try? await newItem?.loadTransferable(type: Data.self),
                              let image = UIImage(data: data) else { return }
                        await MainActor.run {
                            selectedImage = image
                            verificationResult = nil
                            errorMessage = nil
                        }
                    }
                }

                if let selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                submitButton

                if let errorMessage {
                    Text(errorMessage)
                        .fontStyle(.body2Medium)
                        .foregroundStyle(ColorSystem.semanticNegativeHeavy)
                }

                Text("검사 후 앱과 동일한 바텀시트가 열립니다. 콘솔에서 🔑 / 🤖 로그도 확인하세요.")
                    .fontStyle(.detail1Medium)
                    .foregroundStyle(ColorSystem.labelNormalBasic)
            }
            .padding(24)
        }
        .navigationTitle("실제 AI 검사")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showVerificationSheet) {
            PhotoVerificationSheet(
                result: verificationResult,
                failed: verificationFailed,
                onConfirm: { showVerificationSheet = false },
                onRetry: {
                    showVerificationSheet = false
                    selectedPhoto = nil
                    selectedImage = nil
                    verificationResult = nil
                }
            )
            .presentationDetents([.height(480)])
            .presentationDragIndicator(.visible)
        }
    }

    private var submitButton: some View {
        Button {
            Task { await runVerification() }
        } label: {
            Group {
                if isVerifying {
                    VerifyingOverlayView()
                } else {
                    Text("챌린지 인증하기")
                        .fontStyle(.heading2Bold)
                        .foregroundStyle(
                            selectedImage == nil
                            ? ColorSystem.labelNormalBasic
                            : ColorSystem.labelWhite
                        )
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                selectedImage == nil && !isVerifying
                ? ColorSystem.labelNormalAlternative
                : ColorSystem.primaryStrong
            )
            .cornerRadius(20)
        }
        .disabled(selectedImage == nil || isVerifying)
    }

    private var apiKeyStatus: some View {
        let key = Bundle.main.object(forInfoDictionaryKey: "ANTHROPIC_API_KEY") as? String ?? ""
        let isConfigured = !key.isEmpty && !key.hasPrefix("YOUR_")

        return HStack(spacing: 8) {
            Image(systemName: isConfigured ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .foregroundStyle(isConfigured ? ColorSystem.primaryStrong : ColorSystem.semanticNegativeHeavy)
            Text(isConfigured ? "API 키 설정됨 (실제 Claude 호출)" : "API 키 없음 (목업 결과만 반환)")
                .fontStyle(.detail1Medium)
                .foregroundStyle(ColorSystem.labelNormalBasic)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ColorSystem.labelNormalDisable)
        .cornerRadius(12)
    }

    private func runVerification() async {
        guard let selectedImage else { return }

        isVerifying = true
        errorMessage = nil
        verificationResult = nil
        verificationFailed = false

        do {
            let result = try await service.verify(image: selectedImage, context: sampleContext)
            await MainActor.run {
                verificationResult = result
            }
        } catch {
            await MainActor.run {
                verificationFailed = true
                errorMessage = error.localizedDescription
            }
        }

        await MainActor.run {
            isVerifying = false
            showVerificationSheet = true
        }
    }
}
