import SwiftUI
import CryptoKit

// MARK: - Memory Map

final class ImageCacheMemoryMap {
    private let urlCache = NSCache<NSURL, NSData>()
    private let imageCache = NSCache<NSURL, UIImage>()

    init() {
        urlCache.countLimit = 50
        imageCache.countLimit = 50
    }

    func cachedData(for url: URL) -> Data? {
        urlCache.object(forKey: url as NSURL) as Data?
    }

    func store(data: Data, for url: URL) {
        urlCache.setObject(data as NSData, forKey: url as NSURL)
    }

    func cachedImage(for url: URL) -> UIImage? {
        imageCache.object(forKey: url as NSURL)
    }

    func store(image: UIImage, for url: URL) {
        imageCache.setObject(image, forKey: url as NSURL)
    }
}

// MARK: - Disk Cache Actor

actor ImageCacheService {
    static let shared = ImageCacheService()

    private let memoryMap = ImageCacheMemoryMap()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL

    private init() {
        let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        cacheDirectory = caches.appendingPathComponent("FixrImageCache", isDirectory: true)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    func image(for url: URL) async -> UIImage? {
        // 1. Check memory cache
        if let cached = memoryMap.cachedImage(for: url) {
            return cached
        }

        // 2. Check disk cache
        let diskURL = diskCacheURL(for: url)
        if let data = try? Data(contentsOf: diskURL),
           let image = UIImage(data: data) {
            memoryMap.store(image: image, for: url)
            return image
        }

        // 3. Fetch from network
        guard let (data, response) = try? await URLSession.shared.data(from: url),
              let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200,
              let image = UIImage(data: data) else {
            return nil
        }

        // 4. Store in both caches
        try? data.write(to: diskURL, options: .atomic)
        memoryMap.store(data: data, for: url)
        memoryMap.store(image: image, for: url)

        return image
    }

    func clearDiskCache() {
        try? fileManager.removeItem(at: cacheDirectory)
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }

    private func diskCacheURL(for url: URL) -> URL {
        let hash = SHA256.hash(data: Data(url.absoluteString.utf8))
            .compactMap { String(format: "%02x", $0) }
            .joined()
        return cacheDirectory.appendingPathComponent(hash)
    }
}

// MARK: - CachedAsyncImage View

struct CachedAsyncImage: View {
    private let url: URL?
    private let placeholder: AnyView
    private let contentMode: ContentMode

    @State private var image: UIImage?
    @State private var isLoading = false
    @State private var retryCount = 0
    private let maxRetries = 2

    init(
        url: URL?,
        contentMode: ContentMode = .fill,
        @ViewBuilder placeholder: () -> some View = { Color.fixrCard }
    ) {
        self.url = url
        self.contentMode = contentMode
        self.placeholder = AnyView(placeholder())
    }

    init(
        urlString: String?,
        contentMode: ContentMode = .fill,
        @ViewBuilder placeholder: () -> some View = { Color.fixrCard }
    ) {
        self.url = urlString.flatMap { URL(string: $0) }
        self.contentMode = contentMode
        self.placeholder = AnyView(placeholder())
    }

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if isLoading {
                placeholder
                    .overlay(ProgressView().tint(.fixrMuted))
            } else {
                placeholder
            }
        }
        .task(id: url?.absoluteString) {
            await loadImage()
        }
    }

    @MainActor
    private func loadImage() async {
        guard let url = url else { return }
        isLoading = true
        image = await ImageCacheService.shared.image(for: url)
        isLoading = false

        if image == nil && retryCount < maxRetries {
            retryCount += 1
            try? await Task.sleep(nanoseconds: 500_000_000)
            await loadImage()
        }
    }
}
