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
import UIComponentsShared

@MainActor
public final class ProfileEditViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published public var profileImageURL: String? = nil
    @Published public var selectedImage: UIImage? = nil
    @Published public var selectedPhotoItem: PhotosPickerItem? = nil
    @Published public var selectedDefaultImageName: String? = nil
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
    
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public var isLoadingProfile: Bool = true
    @Published public var isLoadingImage: Bool = false
    
    // MARK: - Private Properties
    private let fetchUserProfileUseCase: FetchUserProfileUseCaseProtocol
    private let updateProfileUseCase: UpdateProfileUseCaseProtocol
    private let updateProfileImageUseCase: UpdateProfileImageUseCaseProtocol
    private let checkNicknameUseCase: CheckNicknameUseCaseProtocol
    private var originalProfile: UserProfileData?
    
    // MARK: - Init
    public init(
        fetchUserProfileUseCase: FetchUserProfileUseCaseProtocol,
        updateProfileUseCase: UpdateProfileUseCaseProtocol,
        updateProfileImageUseCase: UpdateProfileImageUseCaseProtocol,
        checkNicknameUseCase: CheckNicknameUseCaseProtocol
    ) {
        self.fetchUserProfileUseCase = fetchUserProfileUseCase
        self.updateProfileUseCase = updateProfileUseCase
        self.updateProfileImageUseCase = updateProfileImageUseCase
        self.checkNicknameUseCase = checkNicknameUseCase
    }
    
    // MARK: - Load Profile
    public func loadProfile() async {
        isLoadingProfile = true
        
        do {
            let profile = try await fetchUserProfileUseCase.execute()
            originalProfile = profile
            
            // 프로필 데이터로 초기화
            profileImageURL = profile.profileUrl
            // nickname 설정 (didSet이 트리거되지 않도록 직접 상태 설정)
            nickname = profile.nickname
            nicknameState = profile.nickname.isEmpty ? .idle : .filled
            
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
        guard !nickname.isEmpty else { return false }
        
        // 변경사항이 있어야만 저장 가능
        guard let originalProfile = originalProfile else { return false }
        
        // 닉네임이 변경되었는지 확인
        let nicknameChanged = nickname != originalProfile.nickname
        
        // 프로필 이미지가 변경되었는지 확인
        let imageChanged = selectedImage != nil
        
        return nicknameChanged || imageChanged
    }
    
    public var hasChanges: Bool {
        guard let originalProfile = originalProfile else { return false }
        return nickname != originalProfile.nickname || selectedImage != nil
    }
    
    public var originalMotto: String? {
        originalProfile?.resolution
    }
    
    // MARK: - Public Methods
    public func checkNickname() {
        Task {
            nicknameState = .checking
            
            do {
                // 닉네임 형식 검증 (2-10자)
                guard nickname.count >= 2 && nickname.count <= 10 else {
                    nicknameState = .invalidFormat
                    return
                }
                
                // 원래 닉네임과 같으면 유효
                if nickname == originalProfile?.nickname {
                    nicknameState = .valid
                    return
                }
                
                // API 호출하여 중복 체크
                let isAvailable = try await checkNicknameUseCase.execute(nickname)
                
                if isAvailable {
                    nicknameState = .valid
                } else {
                    nicknameState = .invalidDuplicate
                }
            } catch {
                #if DEBUG
                print("❌ Nickname check failed: \(error)")
                #endif
                nicknameState = .invalidFormat
            }
        }
    }
    
    public func selectDefaultImage(named name: String, image: UIImage) {
        selectedImage = image
        selectedDefaultImageName = name
        selectedPhotoItem = nil
    }

    public func loadSelectedImage() async {
        guard let photoItem = selectedPhotoItem else { return }
        
        isLoadingImage = true
        
        // 여러 방법으로 이미지 로드 시도
        // 방법 1: Image 타입으로 직접 로드
        if let loadedImage = try? await photoItem.loadTransferable(type: ImageTransferable.self) {
            selectedImage = loadedImage.image
            selectedDefaultImageName = nil
            isLoadingImage = false
            return
        }
        
        // 방법 2: Data로 로드
        if let data = try? await photoItem.loadTransferable(type: Data.self),
           let image = UIImage(data: data) {
            selectedImage = image
            selectedDefaultImageName = nil
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
                
                // multipart/form-data 바이너리로 전송
                let newImageURL = try await updateProfileImageUseCase.execute(imageData: imageData)
                #if DEBUG
                print("✅ Profile image updated")
                #endif

                // 캐시 갱신: 서버가 동일 URL을 재사용하면 stale 캐시가 남아 새 이미지가 반영되지 않으므로,
                // 새로 업로드한 이미지를 기존/신규 URL 키에 직접 저장한다.
                if let oldURL = originalProfile?.profileUrl, !oldURL.isEmpty {
                    ImageCache.shared.store(image: resizedImage, for: oldURL)
                }
                if !newImageURL.isEmpty {
                    ImageCache.shared.store(image: resizedImage, for: newImageURL)
                }
            }
            
            // 프로필 정보 업데이트 (닉네임만)
            let request = ProfileUpdateRequest(
                nickName: nickname,
                birth: "",
                gender: "OTHER",
                address: "",
                resolution: ""
            )
            
            _ = try await updateProfileUseCase.execute(request: request)
            
            #if DEBUG
            print("✅ Profile saved - nickname: \(nickname)")
            #endif

            // 마이페이지가 프로필 이미지/정보를 다시 읽도록 알림 발송
            NotificationCenter.default.post(name: .profileDidUpdate, object: nil)
            
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
