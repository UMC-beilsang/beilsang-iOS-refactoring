//
//  PatchProfileImage.swift
//  beilsang
//
//  Created by Seyoung on 6/20/24.
//

import Foundation

struct PatchProfileImage : Codable{
    let code: String
    let message: String
    let data: ProfileImageData?
    let success: Bool
}

struct ProfileImageData: Codable {
    let profileImage : String?
}
