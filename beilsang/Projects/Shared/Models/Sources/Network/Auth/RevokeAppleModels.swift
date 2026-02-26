//
//  RevokeAppleModels.swift
//  ModelsShared
//
//  Created by Seyoung Park on 12/26/25.
//

import Foundation

// MARK: - Response
/// 애플 탈퇴 응답: APIResponse 형태로 statusCode, code, message, data(String) 필드 사용
public typealias RevokeAppleResponse = APIResponse<String>

