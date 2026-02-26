//
//  ProfileEditViewModel.swift
//  MyPageFeature
//
//  Created by Seyoung Park on 11/26/25.
//

import Foundation
import Combine
import SwiftUI
import UIKit
import PhotosUI
import UserDomain
import ModelsShared

@MainActor
public final class ProfileEditViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published public var profileImageURL: String? = nil
    @Published public var selectedImage: UIImage? = nil
    @Published public var selectedPhotoItem: PhotosPickerItem? = nil
    @Published public var nickname: String = "" {
        didSet {
            // 닉네임 변경 시 상태 자동 업데이트
            if oldValue != nickname {
                if nickname.isEmpty {
                    nicknameState = .idle
                } else if nicknameState != .checking && nicknameState != .valid && nicknameState != .invalidDuplicate && nicknameState != .invalidFormat {
                    nicknameState = .typing
                }
            }
        }
    }
    @Published public var nicknameState: NicknameState = .idle
    @Published public var birthDate: Date? = nil
    @Published public var selectedGender: String? = nil
    @Published public var address: String = ""
    @Published public var addressDetail: String = ""
    @Published public var selectedMotto: Motto?
    
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public var showBirthDatePicker: Bool = false
    @Published public var showAddressSearch: Bool = false
    @Published public var isLoadingProfile: Bool = true
    @Published public var isLoadingImage: Bool = false
    
    // MARK: - Private Properties
    private let fetchUserProfileUseCase: FetchUserProfileUseCaseProtocol
    private let updateProfileUseCase: UpdateProfileUseCaseProtocol
    private let updateProfileImageUseCase: UpdateProfileImageUseCaseProtocol
    private var originalProfile: UserProfileData?
    
    // MARK: - Constants
    public let availableMottos = Motto.allCases
    
    // MARK: - Init
    public init(
        fetchUserProfileUseCase: FetchUserProfileUseCaseProtocol,
        updateProfileUseCase: UpdateProfileUseCaseProtocol,
        updateProfileImageUseCase: UpdateProfileImageUseCaseProtocol
    ) {
        self.fetchUserProfileUseCase = fetchUserProfileUseCase
        self.updateProfileUseCase = updateProfileUseCase
        self.updateProfileImageUseCase = updateProfileImageUseCase
    }
    
    // MARK: - Load Profile
    public func loadProfile() async {
        isLoadingProfile = true
        
        do {
            let profile = try await fetchUserProfileUseCase.execute()
            originalProfile = profile
            
            // 프로필 데이터로 초기화
            profileImageURL = profile.profileImage
            // nickname 설정 (didSet이 트리거되지 않도록 직접 상태 설정)
            nickname = profile.nickname
            nicknameState = profile.nickname.isEmpty ? .idle : .filled
            
            if let birthString = profile.birth {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                birthDate = formatter.date(from: birthString)
            }
            
            if let gender = profile.gender, !gender.isEmpty {
                switch gender {
                case "MAN":
                    selectedGender = "남자"
                case "WOMAN":
                    selectedGender = "여자"
                case "OTHER":
                    selectedGender = "기타"
                default:
                    // 알 수 없는 값이면 nil 유지 (placeholder 표시)
                    selectedGender = nil
                }
            }
            
            address = profile.address ?? ""
            
            // resolution을 Motto로 변환
            if let resolution = profile.resolution {
                selectedMotto = Motto.allCases.first { $0.title == resolution }
            }
            
            isLoadingProfile = false
        } catch {
            errorMessage = "프로필을 불러오는 데 실패했습니다."
            #if DEBUG
            print("❌ Failed to load profile for edit: \(error)")
            #endif
            isLoadingProfile = false
        }
    }
    
    // MARK: - Computed Properties
    public var canSave: Bool {
        !nickname.isEmpty
    }
    
    public var hasChanges: Bool {
        guard let originalProfile = originalProfile else { return false }
        return nickname != originalProfile.nickname
        // TODO: 다른 필드들도 비교
    }
    
    public var originalMotto: String? {
        originalProfile?.resolution
    }
    
    // MARK: - Public Methods
    public func checkNickname() {
        // TODO: 실제 닉네임 중복 확인 API 호출
        Task {
            nicknameState = .checking
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            // 임시 검증 로직
            if nickname.count < 2 || nickname.count > 15 {
                nicknameState = .invalidFormat
            } else if nickname == originalProfile?.nickname {
                nicknameState = .valid
            } else {
                // TODO: API로 실제 중복 체크
                nicknameState = .valid
            }
        }
    }
    
    public func selectMotto(_ motto: Motto) {
        if selectedMotto == motto {
            selectedMotto = nil
        } else {
            selectedMotto = motto
        }
    }
    
    public func loadSelectedImage() async {
        guard let photoItem = selectedPhotoItem else { return }
        
        isLoadingImage = true
        
        // 여러 방법으로 이미지 로드 시도
        // 방법 1: Image 타입으로 직접 로드
        if let loadedImage = try? await photoItem.loadTransferable(type: ImageTransferable.self) {
            selectedImage = loadedImage.image
            isLoadingImage = false
            return
        }
        
        // 방법 2: Data로 로드
        if let data = try? await photoItem.loadTransferable(type: Data.self),
           let image = UIImage(data: data) {
            selectedImage = image
            isLoadingImage = false
            return
        }
        
        #if DEBUG
        print("❌ Failed to load image with all methods")
        #endif
        
        isLoadingImage = false
    }
    
    public func saveProfile() async -> Bool {
        guard canSave else { return false }
        
        isLoading = true
        errorMessage = nil
        
        // 최소 로딩 시간 보장 (0.5초)
        let startTime = Date()
        
        do {
            // 이미지가 변경되었으면 먼저 이미지 업로드
            if let image = selectedImage {
                // 이미지 리사이즈 (최대 128px) 후 최대 압축 - 서버 제한 때문
                let resizedImage = resizeImage(image, maxDimension: 128)
                guard var imageData = resizedImage.jpegData(compressionQuality: 0.5) else {
                    throw NSError(domain: "ProfileEdit", code: -1, userInfo: [NSLocalizedDescriptionKey: "이미지 변환 실패"])
                }
                
                // 50KB 넘으면 품질 낮춰서 재압축
                if imageData.count > 50 * 1024 {
                    imageData = resizedImage.jpegData(compressionQuality: 0.2) ?? imageData
                }
                
                #if DEBUG
                print("📸 Profile image size: \(imageData.count / 1024)KB")
                #endif
                
                // 순수 base64로 전송
                let base64String = imageData.base64EncodedString()
                
                #if DEBUG
                print("📸 Base64 string length: \(base64String.count) chars")
                #endif
                
                _ = try await updateProfileImageUseCase.execute(imageBase64: base64String)
                #if DEBUG
                print("✅ Profile image updated")
                #endif
            }
            
            // 프로필 정보 업데이트
            let birthString: String
            if let date = birthDate {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                birthString = formatter.string(from: date)
            } else {
                birthString = ""
            }
            
            let genderAPI: String
            switch selectedGender {
            case "남자":
                genderAPI = "MAN"
            case "여자":
                genderAPI = "WOMAN"
            default:
                genderAPI = "OTHER"
            }
            
            let fullAddress = addressDetail.isEmpty ? address : "\(address) \(addressDetail)"
            let resolution = selectedMotto?.title ?? ""
            
            let request = ProfileUpdateRequest(
                nickName: nickname,
                birth: birthString,
                gender: genderAPI,
                address: fullAddress,
                resolution: resolution
            )
            
            _ = try await updateProfileUseCase.execute(request: request)
            
            #if DEBUG
            print("✅ Profile saved - nickname: \(nickname)")
            #endif
            
            // 최소 로딩 시간 보장
            let elapsed = Date().timeIntervalSince(startTime)
            let minLoadingTime: TimeInterval = 0.5
            if elapsed < minLoadingTime {
                try? await Task.sleep(nanoseconds: UInt64((minLoadingTime - elapsed) * 1_000_000_000))
            }
            
            isLoading = false
            return true
        } catch {
            errorMessage = "프로필 저장에 실패했습니다."
            #if DEBUG
            print("❌ Failed to save profile: \(error)")
            #endif
            
            // 에러 시에도 최소 로딩 시간 보장
            let elapsed = Date().timeIntervalSince(startTime)
            let minLoadingTime: TimeInterval = 0.5
            if elapsed < minLoadingTime {
                try? await Task.sleep(nanoseconds: UInt64((minLoadingTime - elapsed) * 1_000_000_000))
            }
            
            isLoading = false
            return false
        }
    }
}

// MARK: - Image Resize Helper
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

// MARK: - Image Transferable
struct ImageTransferable: Transferable {
    let image: UIImage
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            guard let image = UIImage(data: data) else {
                throw TransferError.importFailed
            }
            return ImageTransferable(image: image)
        }
    }
    
    enum TransferError: Error {
        case importFailed
    }
}
