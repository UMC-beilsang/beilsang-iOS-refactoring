//
//  CachedAsyncImage.swift
//  UIComponentsShared
//

import SwiftUI

// MARK: - ImageCache (메모리 + 파일 디스크)

public final class ImageCache: @unchecked Sendable {
    public static let shared = ImageCache()

    // 메모리 캐시: 디코딩된 UIImage
    private let memory: NSCache<NSString, UIImage> = {
        let c = NSCache<NSString, UIImage>()
        c.countLimit = 200
        c.totalCostLimit = 100 * 1024 * 1024 // 100MB
        return c
    }()

    // 파일 디스크 캐시 디렉토리
    private let diskDirectory: URL = {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let dir = caches.appendingPathComponent("beilsang_images", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    private init() {}

    // MARK: - Memory

    public func memoryImage(for key: String) -> UIImage? {
        memory.object(forKey: key as NSString)
    }

    private func storeMemory(_ image: UIImage, for key: String) {
        let cost = Int(image.size.width * image.scale * image.size.height * image.scale * 4)
        memory.setObject(image, forKey: key as NSString, cost: cost)
    }

    // MARK: - Disk

    private func diskURL(for key: String) -> URL {
        // URL을 파일명으로 안전하게 변환
        let safe = key
            .components(separatedBy: .init(charactersIn: "/:?=&#%"))
            .joined(separator: "_")
        let filename = String(safe.suffix(200))
        return diskDirectory.appendingPathComponent(filename)
    }

    public func diskData(for key: String) -> Data? {
        try? Data(contentsOf: diskURL(for: key))
    }

    private func storeDisk(_ data: Data, for key: String) {
        try? data.write(to: diskURL(for: key), options: .atomic)
    }

    // MARK: - Combined store

    public func store(image: UIImage, data: Data, for key: String) {
        storeMemory(image, for: key)
        storeDisk(data, for: key)
    }

    /// 새로 업로드한 이미지를 즉시 캐시에 반영 (URL이 동일해 서버 캐시가 stale일 때 사용)
    public func store(image: UIImage, for key: String) {
        storeMemory(image, for: key)
        if let data = image.jpegData(compressionQuality: 0.9) {
            storeDisk(data, for: key)
        }
    }

    /// 특정 키의 메모리/디스크 캐시 제거
    public func remove(for key: String) {
        memory.removeObject(forKey: key as NSString)
        try? FileManager.default.removeItem(at: diskURL(for: key))
    }
}

// MARK: - CachedAsyncImage

/// 메모리 → 디스크 → 네트워크 순으로 이미지 조회.
/// 서버 Cache-Control 헤더 무관하게 자체 디스크 캐시 사용.
public struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    private let urlString: String?
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder

    @State private var uiImage: UIImage?

    public init(
        url: String?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.urlString = url
        self.content = content
        self.placeholder = placeholder
        // 메모리 캐시 히트 시 첫 렌더링부터 즉시 표시
        if let url, let cached = ImageCache.shared.memoryImage(for: url) {
            _uiImage = State(initialValue: cached)
        }
    }

    public var body: some View {
        Group {
            if let uiImage {
                content(Image(uiImage: uiImage))
            } else {
                placeholder()
            }
        }
        .task(id: urlString) {
            guard uiImage == nil else { return }
            await loadImage()
        }
    }

    private func loadImage() async {
        guard let urlString, !urlString.isEmpty,
              let url = URL(string: urlString) else { return }

        // 1. 메모리 캐시
        if let cached = ImageCache.shared.memoryImage(for: urlString) {
            uiImage = cached
            return
        }

        // scale을 메인 스레드에서 미리 캡처
        let scale = await MainActor.run { UIScreen.main.scale }

        // 2. 디스크 캐시
        if let diskData = await Task.detached(priority: .userInitiated, operation: {
            ImageCache.shared.diskData(for: urlString)
        }).value {
            let img = await Task.detached(priority: .userInitiated) {
                downsample(data: diskData, maxPixel: 600, scale: scale)
            }.value
            if let img {
                ImageCache.shared.store(image: img, data: diskData, for: urlString)
                uiImage = img
            }
            return
        }

        // 3. 네트워크
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { return }

            let img = await Task.detached(priority: .userInitiated) {
                downsample(data: data, maxPixel: 600, scale: scale)
            }.value

            guard let img else { return }

            // 디스크 + 메모리에 저장
            ImageCache.shared.store(image: img, data: data, for: urlString)
            uiImage = img
        } catch {
            // 네트워크 실패 → 플레이스홀더 유지
        }
    }
}

// MARK: - Downsampling

/// CGImageSource 썸네일 방식 - 전체 이미지를 메모리에 올리지 않고 필요한 크기만 디코딩.
private func downsample(data: Data, maxPixel: CGFloat, scale: CGFloat) -> UIImage? {
    let sourceOptions: [CFString: Any] = [
        kCGImageSourceShouldCache: false
    ]
    guard let source = CGImageSourceCreateWithData(data as CFData, sourceOptions as CFDictionary) else {
        return UIImage(data: data)
    }

    let targetSize = maxPixel * scale
    let thumbOptions: [CFString: Any] = [
        kCGImageSourceCreateThumbnailFromImageAlways: true,
        kCGImageSourceShouldCacheImmediately: true,
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceThumbnailMaxPixelSize: targetSize
    ]

    guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, thumbOptions as CFDictionary) else {
        return UIImage(data: data)
    }

    return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
}
