//
//  TextFieldState.swift
//  ModelsShared
//
//  Created by Seyoung Park on 10/3/25.
//

import SwiftUI

public enum TextFieldState {
    case idle           // 비어있음 + 포커스 없음
    case focused        // 비어있음 + 포커스 있음
    case typing         // 텍스트 있음 + 포커스 있음 (확인 전)
    case filled         // 텍스트 있음 + 포커스 없음 (확인 전)
    case valid          // 사용 가능
    case invalidFormat  // 형식 오류
}

