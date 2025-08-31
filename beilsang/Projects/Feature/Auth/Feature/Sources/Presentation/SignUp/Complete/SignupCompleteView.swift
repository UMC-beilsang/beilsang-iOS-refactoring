//
//  SignupCompleteView.swift
//  AuthFeature
//
//  Created by Seyoung Park on 8/30/25.
//

import SwiftUI
import UIComponentsShared
import DesignSystemShared

struct SignupCompleteView: View {
    @ObservedObject var viewModel: SignUpViewModel
    @FocusState private var focusedField: Field?
    private enum Field { case recommender }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 캐릭터들 (배경)
                CompleteCharactersView()
                
                // 텍스트 (전경)
                VStack(spacing: 0) {
                    
                    Spacer().frame(height: UIScreen.main.bounds.height * 0.16)
                    
                    // 텍스트 섹션
                    VStack(spacing: 8) {
                        VStack(spacing: 6) {
                            (
                                Text("비일상")
                                    .foregroundColor(ColorSystem.primaryStrong)
                                + Text("의 새로운 회원이\n된 걸 축하합니다!")
                                    .foregroundColor(ColorSystem.labelNormalStrong)
                            )
                            .fontStyle(Fonts.subHeading1Bold)
                            .multilineTextAlignment(.center)
                        }
                        
                        VStack(spacing: 4) {
                            (
                                Text("비일상")
                                    .foregroundColor(ColorSystem.primaryStrong)
                                + Text("과 함께 일상에서의\n친환경을 실천해 봐요!")
                                    .foregroundColor(ColorSystem.labelNormalStrong)
                            )
                            .fontStyle(Fonts.body1SemiBold)
                            .multilineTextAlignment(.center)
                        }
                        .padding(.top, 12)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
            }
        }
        .background(Color(UIColor.systemBackground))
    }
}

struct CompleteCharactersView: View {
    @State private var animateRed = false
    @State private var animateBlue = false
    @State private var animateGreen = false

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            ZStack {
                Image("characterGreen", bundle: .designSystem)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: screenWidth * 0.28)
                    .position(x: screenWidth * 0.35, y: screenHeight * 0.43)
                    .scaleEffect(animateGreen ? 1.04 : 0.96)
                    .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: animateGreen)
                
                Image("characterRed", bundle: .designSystem)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: screenWidth * 0.55)
                    .position(x: screenWidth * 0.75, y: screenHeight * 0.53)
                    .scaleEffect(animateRed ? 1.03 : 0.97)
                    .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: animateRed)

                Image("characterBlue", bundle: .designSystem)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: screenWidth * 0.6, height: screenWidth * 0.6)
                    .position(x: screenWidth * 0.22, y: screenHeight * 0.63)
                    .scaleEffect(animateBlue ? 1.02 : 0.98)
                    .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: animateBlue)
            }
        }
        .onAppear {
            animateRed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { animateBlue = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { animateGreen = true }
        }
    }
}
