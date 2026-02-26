//
//  ShimmerModifier.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 12/03/25.
//

import SwiftUI

// MARK: - Shimmer Effect
public extension View {
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}

public struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    public init() {}
    
    public func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let diagonal = sqrt(width * width + height * height)
                    
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color.clear, location: 0.0),
                            .init(color: Color.white.opacity(0.6), location: 0.5),
                            .init(color: Color.clear, location: 1.0)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: diagonal * 0.3)
                    .rotationEffect(.degrees(30))
                    .offset(x: phase - diagonal * 0.15, y: -height * 0.5)
                }
            )
            .clipped()
            .onAppear {
                let screenWidth = UIScreen.main.bounds.width
                phase = -screenWidth * 0.5
                
                withAnimation(
                    Animation.linear(duration: 1.5)
                        .repeatForever(autoreverses: false)
                ) {
                    phase = screenWidth * 1.5
                }
            }
    }
}

