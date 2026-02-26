//
//  Keyword.swift
//  ModelsShared
//
//  Created by Seyoung Park on 8/29/25.
//

import Foundation

/// A shared enum representing the predefined challenge categories used across the app.
///
/// - Used for both UI display (title, icon) and server communication (raw values).
/// - Commonly referenced in Challenge creation, filtering, and feed sections.
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
    
    /// API category string used in /api/achievement/feeds/{category}
    public var apiCategory: String {
        switch self {
        case .all: return "ALL"
        case .reusableCup: return "TUMBLER"
        case .refillStation: return "REFILL_STATION"
        case .multiUse: return "MULTIPLE_CONTAINERS"
        case .ecoProduct: return "ECO_PRODUCT"
        case .plogging: return "PLOGGING"
        case .vegan: return "VEGAN"
        case .publicTransport: return "PUBLIC_TRANSPORT"
        case .bicycle: return "BIKE"
        case .recycle: return "RECYCLE"
        }
    }
    
    /// Human-readable title for display in the UI (Korean).
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
    
    /// The icon asset name associated with each keyword.
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

extension Keyword: Identifiable {
    public var id: String { rawValue }
}
