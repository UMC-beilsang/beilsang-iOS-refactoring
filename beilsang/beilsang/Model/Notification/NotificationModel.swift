//
//  NotificationModel.swift
//  beilsang
//
//  Created by Seyoung on 6/20/24.
//

import Foundation

struct NotificationModel: Codable {
    let code: String
    let message: String
    let data: [NotificationDataModel]?
    let success: Bool
}

struct NotificationDataModel: Codable {
    let notificationId: Int
    let challengeId: Int
    let title: String
    let contents: String
    let time: String
}


