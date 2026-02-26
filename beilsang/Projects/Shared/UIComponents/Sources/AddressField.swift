//
//  AddressField.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 11/26/25.
//

import SwiftUI
import DesignSystemShared

public struct AddressField: View {
    @Binding var address: String
    @Binding var addressDetail: String
    @Binding var showAddressSearch: Bool
    @FocusState.Binding var focusedField: AnyHashable?
    let addressDetailFocusValue: AnyHashable?
    let placeholder: String
    let webURL: URL?
    
    public init(
        address: Binding<String>,
        addressDetail: Binding<String>,
        showAddressSearch: Binding<Bool>,
        focusedField: FocusState<AnyHashable?>.Binding,
        addressDetailFocusValue: AnyHashable?,
        placeholder: String = "건물, 지번, 도로명으로 검색해 보세요",
        webURL: URL? = URL(string: "https://30isdead.github.io/Kakao-Postcode/")
    ) {
        self._address = address
        self._addressDetail = addressDetail
        self._showAddressSearch = showAddressSearch
        self._focusedField = focusedField
        self.addressDetailFocusValue = addressDetailFocusValue
        self.placeholder = placeholder
        self.webURL = webURL
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                showAddressSearch = true
            } label: {
                HStack {
                    Image("locationIcon", bundle: .designSystem)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    
                    Text(address.isEmpty ? placeholder : address)
                        .foregroundColor(address.isEmpty ? ColorSystem.labelNormalBasic : ColorSystem.labelNormalStrong)
                        .fontStyle(Fonts.body2Medium)
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .frame(height: 48)
                .background(ColorSystem.labelNormalDisable)
                .cornerRadius(8)
            }
            .sheet(isPresented: $showAddressSearch) {
                if let url = webURL {
                    KakaoPostCodeView(
                        request: URLRequest(url: url),
                        isShowingKakaoWebSheet: $showAddressSearch,
                        address: $address
                    )
                }
            }
            
            Spacer()
                .frame(height: 6)
            
            CustomTextField(
                "(선택) 상세 주소를 입력해 주세요",
                text: $addressDetail
            )
            .focused($focusedField, equals: addressDetailFocusValue)
        }
    }
}






