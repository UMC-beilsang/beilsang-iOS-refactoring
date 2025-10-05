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

@MainActor
class ChallengeCertViewModel: ObservableObject {
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
    
    // MARK: - Private Properties
    private let challengeId: Int
    private let repository: ChallengeRepositoryProtocol
    private let maxImageCount = 5
    private let minReviewLength = 20
    private let maxReviewLength = 200
    
    // MARK: - Initialization
    init(challengeId: Int, repository: ChallengeRepositoryProtocol) {
        self.challengeId = challengeId
        self.repository = repository
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
        return validImageCount >= 1 && isReviewValid && !isSubmitting
    }
    
    func updateReviewValidity(_ isValid: Bool) {
        isReviewValid = isValid
    }
    
    func getDetailedValidationMessage() -> String? {
        let validImageCount = selectedPhotoStates.filter { $0.image != nil }.count
        
        if validImageCount < 1 {
            return "최소 1장의 사진을 등록해 주세요"
        }
        
        if !isReviewValid {
            return "후기는 20~200자 이내로 입력해 주세요"
        }
        
        return nil
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
        
        // TODO: API 호출
        // return await repository.submitCertification(
        //     challengeId: challengeId,
        //     images: validImages,
        //     review: reviewText
        // )
        
        return true
    }
}
