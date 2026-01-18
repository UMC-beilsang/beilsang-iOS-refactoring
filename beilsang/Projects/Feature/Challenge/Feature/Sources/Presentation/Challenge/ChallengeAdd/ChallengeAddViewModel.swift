//
//  ChallengeAddViewModel.swift
//  ChallengeFeature
//
//  Created by Seyoung Park on 10/3/25.
//

import Foundation
import Combine
import SwiftUI
import UIKit
import ModelsShared
import ChallengeDomain
import _PhotosUI_SwiftUI
import UIComponentsShared

public enum ChallengeAddStep: Int, CaseIterable {
    case basic = 0
    case detail
    case confirm
}

public enum NavigationDirection {
    case forward, backward
}

public enum ImagePickerTarget {
    case representative
    case sample
}

@MainActor
public final class ChallengeAddViewModel: ObservableObject {
    // MARK: - 기본 데이터
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var caution: String = ""
    @Published var category: Keyword? = nil
    @Published var startDate: Date? {
        didSet { adjustPracticeCountIfNeeded() }
    }

    @Published var period: ChallengePeriod? {
        didSet { adjustPracticeCountIfNeeded() }
    }
    @Published var practiceCount: Int = 1
    @Published var point: Int = 100
    @Published var representativePhotos: [PhotoState] = []
    @Published var samplePhotos: [PhotoState] = []
    @Published var minPoint: Int = 100
    @Published var checkList: [Bool] = [false, false, false, false, false]
    
    // MARK: - Validation States
    @Published var isDescriptionValid: Bool = false
    @Published var isCautionValid: Bool = true
    
    // MARK: - 진행 상태
    @Published var currentStep: ChallengeAddStep = .basic
    @Published var navigationDirection: NavigationDirection = .forward
    
    // MARK: - UI 상태
    @Published var titleState: TextFieldState = .idle
    @Published var shouldLoseFocus: Bool = false
    @Published var showImagePicker: Bool = false
    @Published var showImageModal: Bool = false
    @Published var selectedPhotoID: UUID? = nil
    @Published var imagePickerTarget: ImagePickerTarget = .representative
    @Published var selectedPhotos: [PhotosPickerItem] = []
    
    private let createChallengeUseCase: CreateChallengeUseCaseProtocol
    private var titleDebounceTask: Task<Void, Never>?
    public let confirmList = [
        "카테고리에 알맞는 챌린지를 만들어 주세요",
        "챌린지 유의사항을 자세히 적어 주세요",
        "챌린지는 등록 후 삭제와 수정이 불가해요",
        "모든 챌린지 인증은 등록자가 해야 해요",
        "챌린지 등록 시 자동으로 챌린지에 참여해요"
    ]
    
    public init(createChallengeUseCase: CreateChallengeUseCaseProtocol) {
        self.createChallengeUseCase = createChallengeUseCase
    }
    
    deinit { titleDebounceTask?.cancel() }
    
    // MARK: - Validation
    var isNextEnabled: Bool {
        switch currentStep {
        case .basic: return validateStep1()
        case .detail: return validateStep2()
        case .confirm: return validateStep3()
        }
    }
    
    private func validateStep1() -> Bool {
        !title.isEmpty &&
        (1...30).contains(title.count) &&
        category != nil &&
        representativePhotos.count >= 1 &&
        period != nil &&
        practiceCount > 0
    }
    
    private func validateStep2() -> Bool {
        isDescriptionValid &&
        isCautionValid &&
        samplePhotos.count >= 1 &&
        minPoint >= 100 &&
        minPoint % 100 == 0
    }
    
    private func validateStep3() -> Bool {
        !checkList.contains(false)
    }
    
    // MARK: - CheckList Handling
    func toggleCheckListItem(at index: Int) {
        guard index < checkList.count else { return }
        checkList[index].toggle()
    }
    
    func isCheckListItemSelected(at index: Int) -> Bool {
        guard index < checkList.count else { return false }
        return checkList[index]
    }
    
    var hasAnyCheckListSelection: Bool {
        checkList.contains(true)
    }
    
    // MARK: - TextField Validation Updates
    func updateDescriptionValidity(_ isValid: Bool) {
        self.isDescriptionValid = isValid
    }
    
    func updateCautionValidity(_ isValid: Bool) {
        self.isCautionValid = isValid
    }
    
    private func adjustPracticeCountIfNeeded() {
        guard let period = period else { return }
        let maxCount = period.maxCount(startDate: startDate)
        if practiceCount > maxCount {
            practiceCount = maxCount
        }
        if practiceCount < 1 {
            practiceCount = 1
        }
    }
    
    // MARK: - Representative Image Handling
    func loadRepresentativeImages(from items: [PhotosPickerItem]) {
        for item in items {
            guard representativePhotos.count < 5 else { break }
            
            let photoID = UUID()
            representativePhotos.append(.loading(id: photoID))
            
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        if let index = representativePhotos.firstIndex(where: { $0.id == photoID }) {
                            representativePhotos[index] = .loaded(id: photoID, image: image)
                        }
                    }
                } else {
                    await MainActor.run {
                        if let index = representativePhotos.firstIndex(where: { $0.id == photoID }) {
                            representativePhotos[index] = .failed(id: photoID)
                        }
                    }
                }
            }
        }
    }

    func removeRepresentativeImage(id: UUID) {
        representativePhotos.removeAll { $0.id == id }
    }
    
    func showRepresentativeImagePicker() {
        imagePickerTarget = .representative
        representativePhotos = []
        selectedPhotos = []
        showImagePicker = true
    }
    
    func showRepresentativeImageModal(id: UUID) {
        imagePickerTarget = .representative
        selectedPhotoID = id
        showImageModal = true
    }
    
    // MARK: - Sample Image Handling
    func loadSampleImages(from items: [PhotosPickerItem]) {
        for item in items {
            guard samplePhotos.count < 4 else { break }
            
            let photoID = UUID()
            samplePhotos.append(.loading(id: photoID))
            
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run {
                        if let index = samplePhotos.firstIndex(where: { $0.id == photoID }) {
                            samplePhotos[index] = .loaded(id: photoID, image: image)
                        }
                    }
                } else {
                    await MainActor.run {
                        if let index = samplePhotos.firstIndex(where: { $0.id == photoID }) {
                            samplePhotos[index] = .failed(id: photoID)
                        }
                    }
                }
            }
        }
    }

    func removeSampleImage(id: UUID) {
        samplePhotos.removeAll { $0.id == id }
    }
    
    func showSampleImagePicker() {
        imagePickerTarget = .sample
        samplePhotos = [] 
        selectedPhotos = []
        showImagePicker = true
    }
    
    func showSampleImageModal(id: UUID) {
        imagePickerTarget = .sample
        selectedPhotoID = id
        showImageModal = true
    }
    
    // MARK: - Counter Controls
    func increasePracticeCount() {
        guard let period = period else { return }
        let maxCount = period.maxCount(startDate: startDate)
        if practiceCount < maxCount {
            practiceCount += 1
        }
    }
    
    func decreasePracticeCount() {
        if practiceCount > 1 {
            practiceCount -= 1
        }
    }

    func increasePoint() {
        if minPoint < 1000 {
            minPoint += 100
        }
    }

    func decreasePoint() {
        if minPoint > 100 {
            minPoint -= 100
        }
    }
    
    // MARK: - Step Navigation
    func nextStep() {
        guard let index = ChallengeAddStep.allCases.firstIndex(of: currentStep),
              index + 1 < ChallengeAddStep.allCases.count else { return }
        withAnimation(.easeInOut) {
            navigationDirection = .forward
            currentStep = ChallengeAddStep.allCases[index + 1]
        }
    }

    func previousStep() {
        guard let index = ChallengeAddStep.allCases.firstIndex(of: currentStep),
              index - 1 >= 0 else { return }
        withAnimation(.easeInOut) {
            navigationDirection = .backward
            currentStep = ChallengeAddStep.allCases[index - 1]
        }
    }
    
    // MARK: - Final Action
    @Published var isCreating: Bool = false
    @Published var createError: String?
    @Published var createdChallengeId: Int?
    
    func createChallenge() {
        guard validateStep1(), validateStep2(), validateStep3() else { return }
        guard let category = category, let period = period, let startDate = startDate else { return }
        
        isCreating = true
        createError = nil
        
        Task {
            do {
                // 날짜 포맷팅
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let startDateString = dateFormatter.string(from: startDate)
                
                // 이미지들을 Data로 변환
                let infoImageData = convertPhotosToData(representativePhotos)
                let certImageData = convertPhotosToData(samplePhotos)
                
                // 챌린지 유의사항을 줄바꿈으로 분리
                let notes = caution.components(separatedBy: "\n").filter { !$0.isEmpty }
                
                let request = ChallengeCreateRequest(
                    title: title,
                    startDate: startDateString,
                    period: mapPeriod(period),
                    totalGoalDay: practiceCount,
                    category: category.apiCategory,
                    details: description,
                    notes: notes,
                    joinPoint: minPoint
                )
                
                let response = try await createChallengeUseCase.execute(
                    request: request,
                    infoImages: infoImageData,
                    certImages: certImageData
                )
                
                await MainActor.run {
                    self.createdChallengeId = response.challengeId
                    self.isCreating = false
                    print("✅ 챌린지 생성 완료 - ID: \(response.challengeId)")
                }
            } catch {
                await MainActor.run {
                    self.isCreating = false
                    self.createError = error.localizedDescription
                    print("❌ 챌린지 생성 실패: \(error)")
                }
            }
        }
    }
    
    // MARK: - 이미지 변환
    private func convertPhotosToData(_ photos: [PhotoState]) -> [Data] {
        var imageDataList: [Data] = []
        
        for photo in photos {
            guard case .loaded(_, let image) = photo else { continue }
            
            // 이미지 리사이즈 (최대 512px) 후 강압축 - 서버 용량 제한
            let resizedImage = resizeImage(image, maxDimension: 512)
            guard var imageData = resizedImage.jpegData(compressionQuality: 0.4) else {
                print("⚠️ Failed to convert image to JPEG data")
                continue
            }
            
            // 100KB 넘으면 더 압축
            if imageData.count > 100 * 1024 {
                imageData = resizedImage.jpegData(compressionQuality: 0.2) ?? imageData
            }
            
            // 그래도 200KB 넘으면 더더 압축
            if imageData.count > 200 * 1024 {
                let smallerImage = resizeImage(image, maxDimension: 256)
                imageData = smallerImage.jpegData(compressionQuality: 0.3) ?? imageData
            }
            
            #if DEBUG
            print("📸 Image size: \(imageData.count / 1024)KB")
            #endif
            
            imageDataList.append(imageData)
        }
        
        return imageDataList
    }
    
    // MARK: - 이미지 리사이즈
    private func resizeImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        
        // 이미 충분히 작으면 그대로 반환
        guard size.width > maxDimension || size.height > maxDimension else {
            return image
        }
        
        let ratio = min(maxDimension / size.width, maxDimension / size.height)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    private func mapPeriod(_ period: ChallengePeriod) -> ChallengeCreateRequest.Period {
        switch period {
        case .week: return .week
        case .month: return .month
        }
    }
}
