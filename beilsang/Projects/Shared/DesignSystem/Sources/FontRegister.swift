//
//  FontRegister.swift
//  DesignSystemShared
//
//  Created by Seyoung Park on 8/29/25.
//

import Foundation
import CoreText

public enum FontRegister {
    public static func registerFonts() {
        registerFont("Pretendard-Bold", ext: "otf")
        registerFont("Pretendard-Regular", ext: "otf")
        registerFont("Pretendard-Medium", ext: "otf")
        registerFont("Pretendard-SemiBold", ext: "otf")
        registerFont("NPSfont_regular", ext: "otf")
        registerFont("NPSfont_bold", ext: "otf")
        registerFont("NPSfont_extrabold", ext: "otf")
    }
    
    private static func registerFont(_ name: String, ext: String) {
        guard let url = Bundle.module.url(forResource: name, withExtension: ext),
              let fontDataProvider = CGDataProvider(url: url as CFURL),
              let font = CGFont(fontDataProvider) else {
            print("❌ Failed to load font: \(name)")
            return
        }
        
        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterGraphicsFont(font, &error) {
            print("❌ Failed to register font: \(name), error: \(String(describing: error))")
        }
    }
}
