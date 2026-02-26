//
//  ChallengeAddInfo.swift
//  ModelsShared
//
//  Created by Seyoung Park on 10/3/25.
//
// 입력용 State Data -> ModelShared

import Foundation
import UIKit

public struct ChallengeAddInfo {
    public var representativeImages: [UIImage]
    public var title: String
    public var category: Keyword?
    public var description: String
    public var caution: String
    public var sampleImages: [UIImage]
    public var minPoint: Int
    public var checkList: [Bool]
    public var startDate: Date
    public var period: ChallengePeriod
    
    public init(
            representativeImages: [UIImage] = [],
            title: String = "",
            category: Keyword? = nil,
            description: String = "",
            caution: String = "",
            sampleImages: [UIImage] = [],
            minPoint: Int = 100,
            checkList: [Bool] = [],
            startDate: Date = Date(),
            period: ChallengePeriod = .week
        ) {
            self.representativeImages = representativeImages
            self.title = title
            self.category = category
            self.description = description
            self.caution = caution
            self.sampleImages = sampleImages
            self.minPoint = minPoint
            self.checkList = checkList
            self.startDate = startDate
            self.period = period
        }
        
        public var isFilled: Bool {
            !title.isEmpty &&
            (1...30).contains(title.count) &&
            category != nil &&
            !description.isEmpty &&
            checkList.allSatisfy { $0 }
        }
}

public enum ChallengeInfoField: Hashable {
    case title
    case detail
    case guideLines
}
