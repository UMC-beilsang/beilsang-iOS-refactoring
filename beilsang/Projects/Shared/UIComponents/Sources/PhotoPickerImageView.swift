//
//  PhotoPickerImageView.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 10/3/25.
//

import SwiftUI
import DesignSystemShared
import ModelsShared

public struct PhotoPickerImageView: View {
    let photoState: PhotoState
    let isMainImage: Bool
    let onTap: () -> Void
    let onRemove: () -> Void
    
    public init(
        photoState: PhotoState,
        isMainImage: Bool = false,
        onTap: @escaping () -> Void,
        onRemove: @escaping () -> Void
    ) {
        self.photoState = photoState
        self.isMainImage = isMainImage
        self.onTap = onTap
        self.onRemove = onRemove
    }
    
    public var body: some View {
        ZStack(alignment: .topTrailing) {
            // 이미지 or 플레이스홀더
            if let image = photoState.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipped()
                    .cornerRadius(20)
                    .onTapGesture {
                        if !photoState.isLoading {
                            onTap()
                        }
                    }
            } else {
                // 플레이스홀더 Rectangle
                RoundedRectangle(cornerRadius: 20)
                    .fill(ColorSystem.labelNormalAssistive)
                    .frame(width: 120, height: 120)
                    .overlay {
                        if photoState.isFailed {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(ColorSystem.labelNormalNormal)
                        }
                    }
                    .onTapGesture {
                        if !photoState.isLoading {
                            onTap()
                        }
                    }
            }
            
            // 로딩 오버레이
            if photoState.isLoading {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.6))
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
                .frame(width: 120, height: 120)
            }
            
            // 대표 뱃지
            if isMainImage && !photoState.isLoading {
                HStack {
                    Text("대표")
                        .fontStyle(.detail1Medium)
                        .foregroundStyle(ColorSystem.labelWhite)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(ColorSystem.primaryStrong)
                        .cornerRadius(4)
                    Spacer()
                }
                .padding(.top, 10)
                .padding(.leading, 10)
            }
            
            // 삭제 버튼
            if !photoState.isLoading {
                Button(action: onRemove) {
                    Image("closeIcon", bundle: .designSystem)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
                .padding(10)
            }
        }
    }
}
