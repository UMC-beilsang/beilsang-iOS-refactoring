//
//  LogoutKakaoModels.swift
//  ModelsShared
//
//  Created by Seyoung Park on 12/26/25.
//

import Foundation

// MARK: - Response
/// 카카오 로그아웃 응답: APIResponse 형태로 statusCode, code, message 필드 사용
public typealias LogoutKakaoResponse = APIResponse<EmptyResponse>

