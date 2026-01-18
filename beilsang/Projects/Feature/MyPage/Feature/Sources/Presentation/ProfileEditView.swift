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
    @State private var showMottoSheet: Bool = false
    @State private var showLogoutPopup: Bool = false
    @State private var showRevokeReason: Bool = false
    let webURL: URL? = URL(string: "https://30isdead.github.io/Kakao-Postcode/")
    
    private enum Field: Hashable {
        case nickname
        case addressDetail
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
                            // (화면 전환과 함께 자연스럽게 사라짐)
                            coordinator.pop()
                            
                            // pop 후 토스트 표시 (이전 화면에서 보임)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                // 다짐이 변경되었는지 확인
                                let originalMotto = viewModel.originalMotto
                                let currentMotto = viewModel.selectedMotto?.title
                                
                                if originalMotto != currentMotto {
                                    toastManager.show(
                                        iconName: "toastCheckIcon",
                                        message: "내 다짐을 변경했어요"
                                    )
                                } else {
                                    toastManager.show(
                                        iconName: "toastCheckIcon",
                                        message: "변경사항을 저장했어요"
                                    )
                                }
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
        .fullScreenCover(isPresented: $showMottoSheet) {
            MottoEditView(
                selectedMotto: $viewModel.selectedMotto,
                onSave: {}
            )
        }
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
                    
                    // 내다짐 섹션
                    mottoSection
                    
                    
                    // 생년월일 섹션
                    birthSection
                    
                    // 성별 섹션
                    genderSection
                    
                    // 주소 섹션
                    addressSection
                    
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
        .background(ColorSystem.backgroundNormalAlternative)
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
                    AsyncImage(url: URL(string: profileImageURL)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Image("profilePlaceholderImage", bundle: .designSystem)
                            .resizable()
                            .scaledToFill()
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
            
            PhotosPicker(
                selection: $viewModel.selectedPhotoItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
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
            .onChange(of: viewModel.selectedPhotoItem) { _, _ in
                Task {
                    await viewModel.loadSelectedImage()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
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
    
    // MARK: - Motto Section
    private var mottoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("내다짐")
                .fontStyle(Fonts.heading3Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)
            
            // 다짐 박스 
            if let motto = viewModel.selectedMotto {
                HStack(spacing: 12) {
                    Image(motto.iconName, bundle: .designSystem)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                    
                    Text(motto.title)
                        .fontStyle(.body1Bold)
                        .foregroundStyle(ColorSystem.primaryHeavy)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(ColorSystem.labelNormalDisable)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(ColorSystem.primaryStrong, lineWidth: 2.75)
                )
            } else {
                HStack(spacing: 12) {
                    Text("다짐을 선택해 주세요")
                        .fontStyle(.body1Bold)
                        .foregroundStyle(ColorSystem.labelNormalBasic)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(ColorSystem.labelNormalDisable)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(ColorSystem.labelNormalNormal, lineWidth: 1.5)
                )
            }
            
            // 내 다짐 수정하기 버튼
            Button {
                showMottoSheet = true
            } label: {
                HStack(spacing: 4) {
                    Spacer()
                    Text("내 다짐 수정하기")
                        .fontStyle(.detail1Medium)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10))
                }
                .foregroundStyle(ColorSystem.labelNormalBasic)
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Birth Section
    private var birthSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("생년월일")
                .fontStyle(Fonts.heading3Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)
            
            BirthDateTextField(
                birthDate: $viewModel.birthDate,
                placeholder: "생년월일 8자리"
            )
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Gender Section
    private var genderSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("성별")
                .fontStyle(Fonts.heading3Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)
                .padding(.horizontal, 24)
            
            DropdownField(
                selected: $viewModel.selectedGender,
                placeholder: "성별을 선택해 주세요",
                options: ["여자", "남자", "기타"],
                optionTitle: { $0 }
            )
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Address Section
    private var addressSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("주소")
                .fontStyle(Fonts.heading3Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)
            
            Spacer()
                .frame(height: 12)
            
            AddressField(
                address: $viewModel.address,
                addressDetail: $viewModel.addressDetail,
                showAddressSearch: $viewModel.showAddressSearch,
                focusedField: $focusedField,
                addressDetailFocusValue: Field.addressDetail,
                webURL: webURL
            )
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
        .background(ColorSystem.backgroundNormalAlternative)
    }
}

