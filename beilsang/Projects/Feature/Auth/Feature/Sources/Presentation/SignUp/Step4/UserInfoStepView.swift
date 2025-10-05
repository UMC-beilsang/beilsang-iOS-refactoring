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

struct UserInfoStepView: View {
    @ObservedObject var viewModel: SignUpViewModel
    @FocusState private var focusedField: UserInfoField?
    let webURL: URL? = URL(string: "https://30isdead.github.io/Kakao-Postcode/")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            StepTitleView(title: "비일상에 필요한 정보를\n입력해 주세요")
            
            Spacer()
            
            VStack(spacing: 16) {
                // 닉네임
                nicknameView
                
                // 생년월일
                birthView
                
                // 성별
                genderView
                
                // 주소
                addressView
                
                Spacer()
            }
        }
        .padding(.horizontal, 24)
        .dismissKeyboardOnTap(focusedField: $focusedField)
    }
        
    private var nicknameView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("닉네임")
                .fontStyle(Fonts.heading3Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)
            
            NicknameTextField(
                text: $viewModel.userInfo.nickname,
                state: viewModel.nicknameState,
                onCheckTapped: {
                    viewModel.checkNickname()
                    focusedField = nil
                },
                onClearTapped: {
                    viewModel.userInfo.nickname = ""
                    focusedField = nil
                }
            )
            .focused($focusedField, equals: .nickname)
            .onChange(of: focusedField) { _, newField in
                viewModel.nicknameFocusChanged(isFocused: newField == .nickname)
            }
        }
    }
    
    private var birthView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("생년월일")
                .fontStyle(Fonts.heading3Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)
            
            Button {
                viewModel.showBirthDatePicker = true
            } label: {
                HStack {
                    Text(
                        viewModel.userInfo.birthDate.map { DateFormatter.birthFormatter.string(from: $0) }
                        ?? "생년월일을 선택해 주세요"
                    )
                    .foregroundColor(viewModel.userInfo.birthDate == nil ? ColorSystem.labelNormalBasic : ColorSystem.labelNormalStrong)
                    .fontStyle(Fonts.body2Medium)
                    
                    Spacer()
                    Image("dropDownIcon", bundle: .designSystem)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                .padding(.horizontal, 12)
                .frame(height: 48)
                .background(ColorSystem.labelNormalDisable)
                .cornerRadius(8)
            }
            .sheet(isPresented: $viewModel.showBirthDatePicker) {
                VStack {
                    HStack {
                        Spacer()
                        Button("완료") {
                            viewModel.userInfo.birthDate = viewModel.userInfo.birthDate ?? defaultBirthDate
                            viewModel.showBirthDatePicker = false
                        }
                        .padding()
                    }
                    
                    DatePicker(
                        "생년월일",
                        selection: Binding(
                            get: { viewModel.userInfo.birthDate ?? defaultBirthDate },
                            set: { viewModel.userInfo.birthDate = $0 }
                        ),
                        in: dateRange,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                }
                .presentationDetents([.fraction(0.4)])
                .presentationDragIndicator(.visible)
            }
        }
    }
    
    private var genderView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("성별")
                .fontStyle(Fonts.heading3Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)
            
            DropdownField(
                selected: $viewModel.userInfo.gender,
                placeholder: "성별을 선택해 주세요",
                options: ["여자", "남자", "기타"],
                optionTitle: { $0 }
            )
        }
    }
    
    private var addressView: some View {
        VStack(alignment: .leading) {
            Text("주소")
                .fontStyle(Fonts.heading3Bold)
                .foregroundStyle(ColorSystem.labelNormalStrong)
            
            Spacer()
                .frame(height: 12)
            
            Button {
                viewModel.showAddressSearch = true
            } label: {
                HStack {
                    Image("locationIcon", bundle: .designSystem)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    
                    Text(viewModel.userInfo.address.isEmpty ? "건물, 지번, 도로명으로 검색해 보세요" : viewModel.userInfo.address)
                        .foregroundColor(viewModel.userInfo.address.isEmpty ? ColorSystem.labelNormalBasic : ColorSystem.labelNormalStrong)
                        .fontStyle(Fonts.body2Medium)
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .frame(height: 48)
                .background(ColorSystem.labelNormalDisable)
                .cornerRadius(8)
            }
            .sheet(isPresented: $viewModel.showAddressSearch) {
                if let url = webURL {
                    KakaoPostCodeView(
                        request: URLRequest(url: url),
                        isShowingKakaoWebSheet: $viewModel.showAddressSearch,
                        address: $viewModel.userInfo.address
                    )
                }
            }
            
            Spacer()
                .frame(height: 6)
            
            CustomTextField(
                "(선택) 상세 주소를 입력해 주세요",
                text: $viewModel.userInfo.addressDetail
            )
            .focused($focusedField, equals: .addressDetail)
        }
    }
    
    private var dateRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let start = calendar.date(from: DateComponents(year: 1900, month: 1, day: 1))!
        let end = Date()
        return start...end
    }
    
    private var defaultBirthDate: Date {
        Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 1))!
    }
}

extension DateFormatter {
    static let birthFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy년 MM월 dd일"
        return df
    }()
}
