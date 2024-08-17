//
//  PostAccountInfo.swift
//  beilsang
//
//  Created by 강희진 on 2/10/24.
//

import Foundation
import Alamofire

struct PatchAccountInfo: Codable {
    let success: Bool
    let code: String
    let message: String
    let data: AccountInfoData
}

struct AccountInfoData: Codable {
    let nickName: String
    let birth: String
    let gender: String
    let address: String
}


