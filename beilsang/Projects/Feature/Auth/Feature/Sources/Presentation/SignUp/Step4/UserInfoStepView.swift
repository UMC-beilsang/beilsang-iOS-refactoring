//
//  UserInfoStepView.swift
//  AuthFeature
//
//  Created by Park Seyoung on 8/28/25.
//

import SwiftUI
import UIComponentsShared
import DesignSystemShared
import ModelsShared
import UtilityShared

// 추후 복구 시 사용 예정

struct UserInfoStepView: View {
    @ObservedObject var viewModel: SignUpViewModel
    @FocusState private var focusedField: AnyHashable?
    let webURL: URL? = URL(string: "https://30isdead.github.io/Kakao-Postcode/")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            StepTitleView(title: "비일상에 필요한 정보를\n입력해 주세요")
            
            Spacer()
            
            Text("현재 사용하지 않는 화면입니다")
                .foregroundColor(.gray)
            
            // VStack(spacing: 16) {
            //     // 닉네임
            //     nicknameView
            //     
            //     // 생년월일
            //     birthView
            //     
            //     // 성별
            //     genderView
            //     
            //     // 주소
            //     addressView
            //     
            //     Spacer()
            // }
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .dismissKeyboardOnTap(focusedField: $focusedField)
        // .onChange(of: focusedField) { oldValue, newValue in
        //     if newValue as? UserInfoField == .nickname {
        //         let nickname = viewModel.signUpData.userInfo.nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        //         if nickname.isEmpty {
        //             viewModel.nicknameState = .focused
        //         } else {
        //             viewModel.nicknameState = .typing
        //         }
        //     } else if oldValue as? UserInfoField == .nickname {
        //         let nickname = viewModel.signUpData.userInfo.nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        //         if nickname.isEmpty {
        //             viewModel.nicknameState = .idle
        //         } else if viewModel.nicknameState == .typing || viewModel.nicknameState == .focused {
        //             viewModel.nicknameState = .filled
        //         }
        //     }
        // }
    }
        
    // private var nicknameView: some View {
    //     VStack(alignment: .leading, spacing: 12) {
    //         Text("닉네임")
    //             .fontStyle(Fonts.heading3Bold)
    //             .foregroundStyle(ColorSystem.labelNormalStrong)
    //         
    //         NicknameTextField(
    //             text: $viewModel.signUpData.userInfo.nickname,
    //             state: viewModel.nicknameState,
    //             onCheckTapped: {
    //                 viewModel.checkNickname()
    //                 focusedField = nil
    //             },
    //             onClearTapped: {
    //                 viewModel.signUpData.userInfo.nickname = ""
    //                 focusedField = nil
    //             }
    //         )
    //         .focused($focusedField, equals: UserInfoField.nickname)
    //     }
    // }
    
    // private var birthView: some View {
    //     VStack(alignment: .leading, spacing: 12) {
    //         Text("생년월일")
    //             .fontStyle(Fonts.heading3Bold)
    //             .foregroundStyle(ColorSystem.labelNormalStrong)
    //         
    //         BirthDateTextField(
    //             birthDate: $viewModel.signUpData.userInfo.birthDate,
    //             placeholder: "생년월일 8자리"
    //         )
    //     }
    // }
    
    // private var genderView: some View {
    //     VStack(alignment: .leading, spacing: 12) {
    //         Text("성별")
    //             .fontStyle(Fonts.heading3Bold)
    //             .foregroundStyle(ColorSystem.labelNormalStrong)
    //         
    //         DropdownField(
    //             selected: $viewModel.signUpData.userInfo.gender,
    //             placeholder: "성별을 선택해 주세요",
    //             options: ["여자", "남자", "기타"],
    //             optionTitle: { $0 }
    //         )
    //     }
    // }
    
    // private var addressView: some View {
    //     VStack(alignment: .leading) {
    //         Text("주소")
    //             .fontStyle(Fonts.heading3Bold)
    //             .foregroundStyle(ColorSystem.labelNormalStrong)
    //         
    //         Spacer()
    //             .frame(height: 12)
    //         
    //         AddressField(
    //             address: $viewModel.signUpData.userInfo.address,
    //             addressDetail: $viewModel.signUpData.userInfo.addressDetail,
    //             showAddressSearch: $viewModel.showAddressSearch,
    //             focusedField: $focusedField,
    //             addressDetailFocusValue: UserInfoField.addressDetail,
    //             webURL: webURL
    //         )
    //     }
    // }
}

enum UserInfoField: Hashable {
    case nickname
    case addressDetail
}
