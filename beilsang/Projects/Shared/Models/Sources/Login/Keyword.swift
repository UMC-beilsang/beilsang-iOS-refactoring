//
//  Keyword.swift
//  ModelsShared
//
//  Created by Seyoung Park on 8/29/25.
//

import Foundation

public enum Keyword: String, CaseIterable, Hashable, Equatable, Codable {
    case all = "all"       
    case reusableCup = "reusable_cup"
    case refillStation = "refill_station"
    case multiUse = "multi_use"
    case ecoProduct = "eco_product"
    case plogging = "plogging"
    case vegan = "vegan"
    case publicTransport = "public_transport"
    case bicycle = "bicycle"
    case recycle = "recycle"
    
    public var title: String {
        switch self {
        case .all: return "전체"
        case .reusableCup: return "다회용컵"
        case .refillStation: return "리필스테이션"
        case .multiUse: return "다회용기"
        case .ecoProduct: return "친환경제품"
        case .plogging: return "플로깅"
        case .vegan: return "비건"
        case .publicTransport: return "대중교통"
        case .bicycle: return "자전거"
        case .recycle: return "재활용"
        }
    }
    
    public var iconName: String {
        switch self {
        case .all: return "all"
        case .reusableCup: return "reusableCup"
        case .refillStation: return "refillStation"
        case .multiUse: return "reusableContainer"
        case .ecoProduct: return "ecoProduct"
        case .plogging: return "plogging"
        case .vegan: return "vegan"
        case .publicTransport: return "publicTransit"
        case .bicycle: return "bicycle"
        case .recycle: return "recycle"
        }
    }
}
