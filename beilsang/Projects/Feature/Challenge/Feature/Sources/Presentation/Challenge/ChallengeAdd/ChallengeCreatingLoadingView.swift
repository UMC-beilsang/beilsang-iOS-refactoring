//
//  ChallengeCreatingLoadingView.swift
//  ChallengeFeature
//

import SwiftUI
import UIComponentsShared

struct ChallengeCreatingLoadingView: View {
    var body: some View {
        DotsLoadingView(style: .overlay(message: "챌린지를 만들고 있어요..."))
    }
}
