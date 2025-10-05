//
//  CustomPhotoPickerView.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 10/3/25.
//

import SwiftUI
import DesignSystemShared
import ModelsShared

public struct CustomPhotoPickerView: View {
    @Binding private var photos: [PhotoState]
    private let maxPhotoCount: Int
    private let onAddTapped: () -> Void
    private let onImageTapped: (UUID) -> Void
    private let onRemoveTapped: (UUID) -> Void
    
    public init(
        photos: Binding<[PhotoState]>,
        maxPhotoCount: Int = 5,
        onAddTapped: @escaping () -> Void,
        onImageTapped: @escaping (UUID) -> Void,
        onRemoveTapped: @escaping (UUID) -> Void
    ) {
        self._photos = photos
        self.maxPhotoCount = maxPhotoCount
        self.onAddTapped = onAddTapped
        self.onImageTapped = onImageTapped
        self.onRemoveTapped = onRemoveTapped
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    addPhotoButton
                    ForEach(photos) { photo in
                        PhotoPickerImageView(
                            photoState: photo,
                            isMainImage: photo.id == photos.first?.id,
                            onTap: { onImageTapped(photo.id) },
                            onRemove: { onRemoveTapped(photo.id) }
                        )
                    }
                }
                .padding(.horizontal, 24)
            }
            .padding(.horizontal, -24)
        }
    }
    
    private var addPhotoButton: some View {
        Button(action: onAddTapped) {
            VStack(spacing: 2) {
                Image("cameraIcon", bundle: .designSystem)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                
                Text("사진 등록하기")
                    .fontStyle(.body2SemiBold)
                    .foregroundStyle(ColorSystem.labelNormalNormal)
                
                HStack(spacing: 0) {
                    Text("\(photos.count) ")
                        .fontStyle(.detail1Medium)
                        .foregroundStyle(ColorSystem.primaryStrong)
                    
                    Text("/ \(maxPhotoCount)")
                        .fontStyle(.detail1Medium)
                        .foregroundStyle(ColorSystem.labelNormalNormal)
                }
            }
            .frame(width: 120, height: 120)
            .background(ColorSystem.labelNormalDisable)
            .cornerRadius(20)
        }
        .disabled(photos.count >= maxPhotoCount)
    }
}
