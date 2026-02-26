//
//  ImageModalView.swift
//  UIComponentsShared
//
//  Created by Seyoung Park on 10/4/25.
//

import SwiftUI
import ModelsShared

public struct ImageModalView: View {
    let photos: [PhotoState]?
    let uiImages: [UIImage]?
    let assetNames: [String]?
    @Binding var selectedID: UUID?
    @Binding var isPresented: Bool
    
    @State private var selectedIndex: Int = 0
    
    // PhotoState 기반 초기화
    public init(
        photos: [PhotoState],
        selectedID: Binding<UUID?>,
        isPresented: Binding<Bool>
    ) {
        self.photos = photos
        self.uiImages = nil
        self.assetNames = nil
        self._selectedID = selectedID
        self._isPresented = isPresented
    }
    
    // UIImage 배열 기반 초기화 (하위 호환성)
    public init(
        uiImages: [UIImage],
        selectedIndex: Binding<Int>,
        isPresented: Binding<Bool>
    ) {
        self.photos = nil
        self.uiImages = uiImages
        self.assetNames = nil
        self._selectedID = .constant(nil)
        self._isPresented = isPresented
        self._selectedIndex = State(initialValue: selectedIndex.wrappedValue)
    }
    
    // Asset 이름 기반 초기화 (하위 호환성)
    public init(
        assetNames: [String],
        selectedIndex: Binding<Int>,
        isPresented: Binding<Bool>
    ) {
        self.photos = nil
        self.uiImages = nil
        self.assetNames = assetNames
        self._selectedID = .constant(nil)
        self._isPresented = isPresented
        self._selectedIndex = State(initialValue: selectedIndex.wrappedValue)
    }
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    let count = getImageCount()
                    if count > 0 {
                        Text("\(getCurrentIndex() + 1) / \(count)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                // Image Paging
                ZStack(alignment: .bottom) {
                    if let photos = photos {
                        photoStateTabView(photos: photos)
                    } else if let uiImages = uiImages {
                        uiImageTabView(images: uiImages)
                    } else if let assetNames = assetNames {
                        assetNameTabView(names: assetNames)
                    }
                    
                    // Indicator
                    let count = getImageCount()
                    if count > 1 {
                        HStack(spacing: 8) {
                            ForEach(0..<count, id: \.self) { index in
                                Circle()
                                    .fill(index == getCurrentIndex() ? Color.white : Color.white.opacity(0.5))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.6))
                        )
                        .padding(.bottom, 30)
                    }
                }
                
                Spacer()
            }
        }
        .onAppear {
            if let photos = photos, let selectedID = selectedID {
                selectedIndex = photos.firstIndex(where: { $0.id == selectedID }) ?? 0
            }
        }
    }
    
    // MARK: - PhotoState TabView
    @ViewBuilder
    private func photoStateTabView(photos: [PhotoState]) -> some View {
        TabView(selection: $selectedIndex) {
            ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
                if let image = photo.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .tag(index)
                } else {
                    // 로딩 중이거나 실패한 경우
                    ZStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                        
                        if photo.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                        } else if photo.isFailed {
                            VStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                                Text("이미지를 불러올 수 없습니다")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .tag(index)
                }
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .onChange(of: selectedIndex) { newIndex in
            if let photos = self.photos, photos.indices.contains(newIndex) {
                selectedID = photos[newIndex].id
            }
        }
    }
    
    // MARK: - UIImage TabView
    @ViewBuilder
    private func uiImageTabView(images: [UIImage]) -> some View {
        TabView(selection: $selectedIndex) {
            ForEach(images.indices, id: \.self) { index in
                Image(uiImage: images[index])
                    .resizable()
                    .scaledToFit()
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
    
    // MARK: - Asset Name TabView
    @ViewBuilder
    private func assetNameTabView(names: [String]) -> some View {
        TabView(selection: $selectedIndex) {
            ForEach(Array(names.enumerated()), id: \.offset) { index, name in
                Image(name)
                    .resizable()
                    .scaledToFit()
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
    
    // MARK: - Helper Methods
    private func getImageCount() -> Int {
        if let photos = photos {
            return photos.count
        } else if let uiImages = uiImages {
            return uiImages.count
        } else if let assetNames = assetNames {
            return assetNames.count
        }
        return 0
    }
    
    private func getCurrentIndex() -> Int {
        return selectedIndex
    }
}
