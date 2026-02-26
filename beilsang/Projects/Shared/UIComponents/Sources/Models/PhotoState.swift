//
//  PhotoState.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 10/4/25.
//

import SwiftUI

public enum PhotoState: Identifiable {
    case loading(id: UUID)
    case loaded(id: UUID, image: UIImage)
    case failed(id: UUID)
    
    public var id: UUID {
        switch self {
        case .loading(let id), .loaded(let id, _), .failed(let id):
            return id
        }
    }
    
    public var image: UIImage? {
        if case .loaded(_, let image) = self {
            return image
        }
        return nil
    }
    
    public var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    public var isFailed: Bool {
        if case .failed = self { return true }
        return false
    }
}
