//
//  Bundle.swift
//  UtilityShared
//
//  Created by Seyoung Park on 8/29/25.
//

import Foundation

public extension Bundle {
    static var utility: Bundle {
        Bundle(for: Dummy.self)
    }

    private class Dummy {}
}
