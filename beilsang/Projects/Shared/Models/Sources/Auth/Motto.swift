//
//  Motto.swift
//  ModelsShared
//
//  Created by Seyoung Park on 8/29/25.
//

import Foundation

/// A shared enum representing user environmental mottos / themes.
///
/// - Used for displaying personalized UI elements (title, icon) and possibly for server communication.
/// - Represents how users identify themselves in terms of eco-friendly behavior (e.g., vegan, plogging).
public enum Motto: String, CaseIterable, Identifiable, Equatable, Codable {
    public var id: String { rawValue }
    
    case ecoProduct      = "eco_product"
    case publicTransit   = "public_transit"
    case bicycle         = "bicycle"
    case plogging        = "plogging"
    case vegan           = "vegan"
    
    /// A human-readable Korean title describing each motto.
    public var title: String {
        switch self {
        case .ecoProduct: return "환경보호에 앞장서는 나"
        case .publicTransit: return "일상생활 속 꾸준하게 실천하는 나"
        case .bicycle: return "건강한 지구를 위해 노력하는 나"
        case .plogging: return "다양한 친환경 활동을 배워가는 나"
        case .vegan: return "자연과의 조화를 이루는 나"
        }
    }
    
    /// The icon asset name associated with each motto.
    public var iconName: String {
        switch self {
        case .ecoProduct: return "ecoProduct"
        case .publicTransit: return "publicTransit"
        case .bicycle: return "bicycle"
        case .plogging: return "plogging"
        case .vegan: return "vegan"
        }
    }
}
