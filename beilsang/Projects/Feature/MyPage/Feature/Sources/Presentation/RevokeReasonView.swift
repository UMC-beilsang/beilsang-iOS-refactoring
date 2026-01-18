//
//  RevokeReasonView.swift
//  MyPageFeature
//
//  Created by Seyoung Park on 12/18/25.
//

import SwiftUI
import UIComponentsShared
import DesignSystemShared
import NavigationShared

public struct RevokeReasonView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appRouter: AppRouter
    
    @State private var selectedReason: RevokeReason?
    @State private var otherReasonText: String = ""
    @State private var showConfirmPopup: Bool = false
    
    let availableReasons = RevokeReason.allCases
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 헤더
            Header(type: .secondary(
                title: "회원탈퇴",
                onBack: { dismiss() }
            ))
            
            VStack(alignment: .leading, spacing: 0) {
                // 제목
                StepTitleView(title: "탈퇴 사유를 알려 주세요")
                    .padding(.horizontal, 24)
                    .padding(.top, 32)
                
                Text("더 나은 서비스를 위한 소중한 의견 부탁드립니다")
                    .fontStyle(Fonts.body1Medium)
                    .foregroundStyle(ColorSystem.labelNormalBasic)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                
                Spacer()
                    .frame(height: 64)
                
                // 탈퇴 사유 리스트
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(availableReasons, id: \.self) { reason in
                            SelectableItemView(
                                title: reason.title,
                                isSelected: selectedReason == reason,
                                hasAnySelection: selectedReason != nil,
                                onTap: {
                                    if selectedReason == reason {
                                        selectedReason = nil
                                        otherReasonText = ""
                                    } else {
                                        selectedReason = reason
                                        if reason != .other {
                                            otherReasonText = ""
                                        }
                                    }
                                }
                            )
                        }
                        
                        // 기타 선택 시 입력 필드
                        if selectedReason == .other {
                            CustomTextField(
                                "아쉬웠던 점이 있다면 자유롭게 작성해 주세요",
                                text: $otherReasonText
                            )
                            .padding(.top, 8)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 120)
                }
            }
            
            // 하단 버튼
            VStack {
                NextStepButton(
                    title: "탈퇴하기",
                    isEnabled: isValidInput,
                    onTap: {
                        showConfirmPopup = true
                    }
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 34)
            }
            .background(ColorSystem.backgroundNormalNormal)
        }
        .background(ColorSystem.backgroundNormalNormal)
        .toolbar(.hidden, for: .navigationBar)
        // 탈퇴 확인 팝업
        .overlay {
            if showConfirmPopup {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showConfirmPopup = false
                    }
                
                PopupView(
                    title: "정말 탈퇴할까요?",
                    style: .alert(
                        message: "지금 탈퇴하면 참여 중인 챌린지 패배 처리가",
                        subMessage: "진행 되고 보상금 받을 기회가 모두 사라져요"
                    ),
                    primary: PopupAction(title: "탈퇴하기") {
                        showConfirmPopup = false
                        // 탈퇴 실행
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            appRouter.revoke()
                        }
                    },
                    secondary: PopupAction(title: "취소") {
                        showConfirmPopup = false
                    }
                )
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showConfirmPopup)
        .animation(.easeInOut(duration: 0.3), value: selectedReason)
    }
    
    // MARK: - Computed Properties
    private var isValidInput: Bool {
        guard let reason = selectedReason else { return false }
        
        if reason == .other {
            return !otherReasonText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        
        return true
    }
}

// MARK: - Revoke Reason
enum RevokeReason: CaseIterable, Hashable {
    case appNotUseful
    case contentNotSatisfied
    case featureNotWorking
    case serviceNotUsing
    case other
    
    var title: String {
        switch self {
        case .appNotUseful:
            return "앱이용이 불편했어요"
        case .contentNotSatisfied:
            return "콘텐츠가 별로였어요"
        case .featureNotWorking:
            return "서비스에 원하는 기능이 없어요"
        case .serviceNotUsing:
            return "서비스를 잘 사용하지 않아요"
        case .other:
            return "기타 (직접 입력)"
        }
    }
}

#if DEBUG
struct RevokeReasonView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RevokeReasonView()
                .environmentObject(AppRouter())
        }
    }
}
#endif
