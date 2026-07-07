//
//  ChallengeCertViewModel.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 9/17/25.
//

import SwiftUI
import PhotosUI
import ChallengeDomain
import ModelsShared
import UIComponentsShared

// MARK: - ViewModel

@MainActor
public final class ChallengeCertViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedPhotoStates: [PhotoState] = []
    @Published var selectedPhotos: [PhotosPickerItem] = []
    @Published var reviewText: String = ""
    @Published var isReviewValid: Bool = false
    @Published var showImagePicker = false
    @Published var showGuideModal = true
    @Published var isSubmitting = false
    @Published var showImageModal = false
    @Published var selectedPhotoID: UUID? = nil
    @Published var certImages: [String] = []

    // AI 검증 관련
    @Published var isVerifying = false
    @Published var showVerificationSheet = false
    @Published var verificationResult: PhotoVerificationResult? = nil
    @Published var verificationFailed = false

    // MARK: - Private Properties
    private let challengeId: Int
    private let feedRepo: FeedRepositoryProtocol
    private let verificationService: PhotoVerificationService
    private let challengeContext: ChallengeVerificationContext?
    private let maxImageCount = 5

    // MARK: - Initialization

    public init(
        challengeId: Int,
        feedRepo: FeedRepositoryProtocol,
        challengeContext: ChallengeVerificationContext? = nil
    ) {
        self.challengeId = challengeId
        self.feedRepo = feedRepo
        self.challengeContext = challengeContext
        self.verificationService = PhotoVerificationService.fromBundle()
        loadCertImages()
    }

    // MARK: - Image Handling

    func loadImages(from items: [PhotosPickerItem]) {
        for item in items {
            guard selectedPhotoStates.count < maxImageCount else { break }

            let photoID = UUID()
            selectedPhotoStates.append(.loading(id: photoID))

            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        if let index = selectedPhotoStates.firstIndex(where: { $0.id == photoID }) {
                            selectedPhotoStates[index] = .loaded(id: photoID, image: image)
                        }
                    }
                } else {
                    await MainActor.run {
                        if let index = selectedPhotoStates.firstIndex(where: { $0.id == photoID }) {
                            selectedPhotoStates[index] = .failed(id: photoID)
                        }
                    }
                }
            }
        }
    }

    func removeImage(id: UUID) {
        selectedPhotoStates.removeAll { $0.id == id }
    }

    func showImageSelector() {
        selectedPhotoStates = []
        selectedPhotos = []
        showImagePicker = true
    }

    /// AI 검증 실패 후 재시도: 기존 사진 초기화 없이 picker만 오픈
    func showImageSelectorForRetry() {
        selectedPhotos = []
        showImagePicker = true
    }

    func showImageModal(id: UUID) {
        selectedPhotoID = id
        showImageModal = true
    }

    // MARK: - Modal Control

    func dismissGuideModal() {
        showGuideModal = false
    }

    // MARK: - Validation

    var canSubmit: Bool {
        let validImageCount = selectedPhotoStates.filter { $0.image != nil }.count
        return validImageCount >= 1 && isReviewValid && !isSubmitting && !isVerifying
    }

    func updateReviewValidity(_ isValid: Bool) {
        isReviewValid = isValid
    }

    func getDetailedValidationMessage() -> String? {
        let validImageCount = selectedPhotoStates.filter { $0.image != nil }.count
        if validImageCount < 1 { return "최소 1장의 사진을 등록해 주세요" }
        if !isReviewValid { return "후기는 20~200자 이내로 입력해 주세요" }
        return nil
    }

    // MARK: - AI Verification + Submit Flow

    /// 제출 버튼 탭 시 호출: AI 검증 후 결과 시트 표시
    func verifyBeforeSubmit() async {
        guard let firstImage = selectedPhotoStates.compactMap({ $0.image }).first else { return }

        guard let context = challengeContext else {
            verificationFailed = true
            showVerificationSheet = true
            return
        }

        isVerifying = true
        verificationResult = nil
        verificationFailed = false

        do {
            let result = try await verificationService.verify(image: firstImage, context: context)
            verificationResult = result
        } catch {
            verificationFailed = true
            #if DEBUG
            print("❌ AI 검증 실패: \(error.localizedDescription)")
            #endif
        }

        isVerifying = false
        showVerificationSheet = true
    }

    func dismissVerificationSheet() {
        showVerificationSheet = false
    }

    // MARK: - API

    private func loadCertImages() {
        // TODO: API 호출해서 certImages 로드
        certImages = []
    }

    func submitCertification() async -> Bool {
        guard !isSubmitting else { return false }

        let validImages = selectedPhotoStates.compactMap { $0.image }
        guard validImages.count >= 1 else { return false }

        isSubmitting = true
        defer { isSubmitting = false }

        do {
            guard let firstImage = validImages.first,
                  let imageData = firstImage.jpegData(compressionQuality: 0.8) else {
                return false
            }

            let request = FeedCreateRequest(
                challengeId: challengeId,
                content: reviewText
            )

            let result = try await feedRepo.createFeed(request: request, feedImage: imageData)

            #if DEBUG
            print("✅ Feed created successfully - feedId: \(result.feedId)")
            #endif

            return true
        } catch {
            #if DEBUG
            print("❌ Failed to create feed: \(error)")
            #endif
            return false
        }
    }
}
