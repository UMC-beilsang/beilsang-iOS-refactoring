//
//  NicknameState.swift
//  ModelsShared
//
//  Created by Seyoung Park on 8/30/25.
//

import Foundation

public enum NicknameState {
    case idle           // 비어있음 + 포커스 없음
    case focused        // 비어있음 + 포커스 있음  
    case typing         // 텍스트 있음 + 포커스 있음 (확인 전)
    case filled         // 텍스트 있음 + 포커스 없음 (확인 전)
    case checking       // 중복 확인 중
    case valid          // 사용 가능
    case invalidFormat  // 형식 오류
    case invalidDuplicate // 중복 오류
}
