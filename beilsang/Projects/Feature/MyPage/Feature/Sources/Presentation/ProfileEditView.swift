//
//  ProfileEditView.swift
//  MyPageFeature
//
//  Created by Seyoung Park on 11/26/25.
//

import SwiftUI
import PhotosUI
import UIComponentsShared
import ModelsShared
import DesignSystemShared
import UtilityShared
import NavigationShared

public struct ProfileEditView: View {
    @StateObject private var viewModel: ProfileEditViewModel
    @EnvironmentObject var coordinator: MyPageCoordinator
    @EnvironmentObject var toastManager: ToastManager
    @EnvironmentObject var appRouter: AppRouter
    @FocusState private var focusedField: AnyHashable?
    @State private var showLogoutPopup: Bool = false
    @State private var showRevokeReason: Bool = false
    @State private var showImageSourceOptions: Bool = false
    @State private var showDefaultImagePicker: Bool = false
    @State private var showPhotosPicker: Bool = false
    
    private enum Field: Hashable {
        case nickname
    }
    
    public init(viewModel: ProfileEditViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Header(type: .secondaryWithSave(
                title: "계정 설정",
                onBack: { coordinator.pop() },
                onSave: {
                    Task {
                        let success = await viewModel.saveProfile()
                        if success {
                            // 로딩 오버레이 보이는 상태로 바로 pop
                            coordinator.pop()
                            
                            // pop 후 토스트 표시
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                toastManager.show(
                                    iconName: "toastCheckIcon",
                                    message: "변경사항을 저장했어요"
                                )
                            }
                        }
                    }
                },
                canSave: viewModel.canSave
            ))
            
            if viewModel.isLoadingProfile {
                VStack(spacing: 16) {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: ColorSystem.primaryNormal))
                    Text("프로필을 불러오는 중...")
                        .fontStyle(.body2Medium)
                        .foregroundStyle(ColorSystem.labelNormalBasic)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                contentView
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .overlay {
            // 로그아웃 팝업
            if showLogoutPopup {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showLogoutPopup = false
                        }
                    
                    PopupView(
                        title: "로그아웃",
                        style: .alert(
                            message: "접속 중인 기기에서 로그아웃할까요?",
                            subMessage: "회원 정보는 사라지지 않아요"
                        ),
                        primary: PopupAction(title: "로그아웃") {
                            showLogoutPopup = false
                            appRouter.logout()
                        },
                        secondary: PopupAction(title: "취소") {
                            showLogoutPopup = false
                        }
                    )
                }
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.2), value: showLogoutPopup)
            }
            
            // 회원탈퇴 화면 네비게이션
            NavigationLink(
                destination: RevokeReasonView()
                    .environmentObject(appRouter),
                isActive: $showRevokeReason
            ) {
                EmptyView()
            }
            
            // 저장 중 로딩 오버레이
            if viewModel.isLoading {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                    .overlay {
                        ProgressView()
                            .scaleEffect(1.3)
                    }
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.15), value: viewModel.isLoading)
            }
        }
        .task {
            await viewModel.loadProfile()
        }
    }
    
    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 32) {
                    // 프로필 이미지 섹션
                    profileImageSection
                    
                    // 닉네임 섹션
                    nicknameSection
                    
                    Spacer().frame(height: 80)
                }
                .padding(.top, 20)
                .background(ColorSystem.backgroundNormalNormal)
                    
                
                // 로그아웃/회원탈퇴 섹션
                accountActionsSection
                
                // 하단 약관 푸터
                termsFooterSection
            }
        }
        .background(ColorSystem.labelNormalDisable)
        .dismissKeyboardOnTap(focusedField: $focusedField)
    }
    
    // MARK: - Profile Image Section
    private var profileImageSection: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .center) {
                // 1순위: 새로 선택한 이미지
                if let selectedImage = viewModel.selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFill()
                }
                // 2순위: 기존 프로필 이미지 URL
                else if let profileImageURL = viewModel.profileImageURL, !profileImageURL.isEmpty {
                    CachedAsyncImage(url: profileImageURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        // 기존 이미지가 있는 경우, 로딩 중에는 기본(보라) 아바타 대신 중립 배경을 보여
                        // 보라색 → 내 이미지로 바뀌며 깜빡이는 현상 방지
                        ZStack {
                            ColorSystem.labelNormalDisable
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: ColorSystem.primaryNormal))
                        }
                    }
                }
                // 3순위: 플레이스홀더
                else {
                    Image("profilePlaceholderImage", bundle: .designSystem)
                        .resizable()
                        .scaledToFill()
                }
                
                // 이미지 로딩 중
                if viewModel.isLoadingImage {
                    Color.black.opacity(0.3)
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
            .frame(width: 88, height: 88)
            .clipShape(Circle())
            
            Button {
                showImageSourceOptions = true
            } label: {
                Text("사진 변경")
                    .fontStyle(.detail1Medium)
                    .foregroundColor(ColorSystem.primaryStrong)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(ColorSystem.primaryAlternative)
                    )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .confirmationDialog("프로필 사진 변경", isPresented: $showImageSourceOptions, titleVisibility: .visible) {
            Button("기본 이미지에서 선택하기") {
                showDefaultImagePicker = true
            }
            Button("사진 보관함에서 선택하기") {
                showPhotosPicker = true
            }
            Button("취소", role: .cancel) {}
        }
        .sheet(isPresented: $showDefaultImagePicker) {
            DefaultProfileImagePickerView(
                currentSelectedName: $viewModel.selectedDefaultImageName,
                onSelect: { name, image in
                    viewModel.selectDefaultImage(named: name, image: image)
                }
            )
            .presentationDetents([.height(290)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(20)
        }
        .photosPicker(isPresented: $showPhotosPicker, selection: $viewModel.selectedPhotoItem, matching: .images)
        .onChange(of: viewModel.selectedPhotoItem) { _, _ in
            Task {
                await viewModel.loadSelectedImage()
            }
        }
    }
    
    // MARK: - Nickname Section
    private var nicknameSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("닉네임")
                .fontStyle(Fonts.heading3Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)
            
            NicknameTextField(
                text: $viewModel.nickname,
                state: viewModel.nicknameState,
                onCheckTapped: {
                    viewModel.checkNickname()
                    focusedField = nil
                },
                onClearTapped: {
                    viewModel.nickname = ""
                    focusedField = nil
                }
            )
            .focused($focusedField, equals: Field.nickname)
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Account Actions Section
    private var accountActionsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Button {
                showLogoutPopup = true
            } label: {
                Text("로그아웃")
                    .fontStyle(.detail1Medium)
                    .foregroundStyle(ColorSystem.labelNormalBasic)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Button {
                showRevokeReason = true
            } label: {
                Text("회원탈퇴")
                    .fontStyle(.detail1Medium)
                    .foregroundStyle(ColorSystem.labelNormalBasic)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 60)
        .background(ColorSystem.backgroundNormalNormal)
    }
    
    // MARK: - Terms Footer Section
    private var termsFooterSection: some View {
        VStack {
            Spacer().frame(height: 80)
            
            HStack(spacing: 8) {
                Button {
                    // TODO: 개인정보처리방침 웹뷰
                    toastManager.show(
                        iconName: "toastCheckIcon",
                        message: "개인정보처리방침 페이지 준비 중입니다"
                    )
                } label: {
                    Text("개인정보처리방침")
                        .fontStyle(.detail1Medium)
                        .foregroundStyle(ColorSystem.labelNormalBasic)
                }
                
                Text("|")
                    .fontStyle(.detail1Medium)
                    .foregroundStyle(ColorSystem.labelNormalBasic)
                
                Button {
                    // TODO: 이용약관 웹뷰
                    toastManager.show(
                        iconName: "toastCheckIcon",
                        message: "이용약관 페이지 준비 중입니다"
                    )
                } label: {
                    Text("이용약관")
                        .fontStyle(.detail1Medium)
                        .foregroundStyle(ColorSystem.labelNormalBasic)
                }
            }
            .frame(maxWidth: .infinity)
            
            Spacer().frame(height: 40)
        }
        .background(ColorSystem.labelNormalDisable)
    }
}

// MARK: - Default Profile Image Picker

private struct DefaultProfileImagePickerView: View {
    @Binding var currentSelectedName: String?
    let onSelect: (String, UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedName: String? = nil

    private let defaultImages = [
        "profilePlaceholderImage",
        "profileGreenImage",
        "profilePinkImage",
        "profileYellowImage",
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("기본 이미지 선택")
                .fontStyle(.heading1Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)
                .padding(.top, 32)
            
            Spacer()

            HStack(spacing: 16) {
                ForEach(defaultImages, id: \.self) { name in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedName = name
                        }
                    } label: {
                        ZStack {
                            Image(name, bundle: .designSystem)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 64, height: 64)
                                .clipShape(Circle())

                            if selectedName == name {
                                Circle()
                                    .stroke(ColorSystem.primaryNormal, lineWidth: 3)
                                    .frame(width: 64, height: 64)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            NextStepButton(
                title: "저장하기",
                isEnabled: selectedName != nil,
                onTap: {
                    guard let name = selectedName else { return }
                    let rendered = renderImage(name: name)
                    onSelect(name, rendered)
                    dismiss()
                }
            )
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(ColorSystem.backgroundNormalNormal)
        .onAppear {
            selectedName = currentSelectedName
        }
    }

    @MainActor
    private func renderImage(name: String) -> UIImage {
        // 흰 배경 + 원형 디스크보다 살짝 크게(overscan) 렌더링.
        // 투명 모서리가 JPEG에서 검정으로 채워지며 생기는 테두리(stroke) 아티팩트 방지.
        let view = Image(name, bundle: .designSystem)
            .resizable()
            .scaledToFill()
            .frame(width: 136, height: 136)
            .frame(width: 128, height: 128)
            .clipped()
            .background(Color.white)
        let renderer = ImageRenderer(content: view)
        renderer.scale = UIScreen.main.scale
        renderer.isOpaque = true
        return renderer.uiImage ?? UIImage()
    }
}
