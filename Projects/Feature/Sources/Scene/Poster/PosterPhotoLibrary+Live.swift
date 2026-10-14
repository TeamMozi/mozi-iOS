import Foundation
import Photos
import ThirdParty
import UIKit

extension PosterPhotoLibrary: DependencyKey {
    public static let liveValue = PosterPhotoLibrary(
        requestAccess: {
            PhotoLibraryAccess(await PHPhotoLibrary.requestAuthorization(for: .readWrite))
        },
        recentPhotos: { limit in
            await PosterPhotoLibraryLive.recentPhotos(limit: limit)
        },
        posterData: { id in
            try await PosterPhotoLibraryLive.posterData(id: id)
        },
        swatchData: { index in
            await PosterPhotoLibraryLive.swatchData(index: index)
        }
    )
}

extension PhotoLibraryAccess {
    init(_ status: PHAuthorizationStatus) {
        switch status {
        case .authorized:
            self = .authorized
        case .limited:
            self = .limited
        case .denied, .restricted, .notDetermined:
            self = .denied
        @unknown default:
            self = .denied
        }
    }
}

private enum PosterPhotoLibraryLive {
    static let thumbnailSize = CGSize(width: 240, height: 320)
    static let posterSize = CGSize(width: 1080, height: 1440)

    static func recentPhotos(limit: Int) async -> [PhotoLibraryItem] {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.fetchLimit = limit
        var identifiers: [String] = []
        PHAsset.fetchAssets(with: .image, options: options).enumerateObjects { asset, _, _ in
            identifiers.append(asset.localIdentifier)
        }
        var items: [PhotoLibraryItem] = []
        for identifier in identifiers {
            if let data = await jpegData(identifier: identifier, size: thumbnailSize, quality: 0.7) {
                items.append(PhotoLibraryItem(id: identifier, thumbnail: data))
            }
        }
        return items
    }

    static func posterData(id: String) async throws -> Data {
        guard let data = await jpegData(identifier: id, size: posterSize, quality: 0.9) else {
            throw PhotoLibraryError.unreadable
        }
        return data
    }

    @MainActor
    static func swatchData(index: Int) -> Data {
        let color = PosterSwatch.uiColor(at: index)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: posterSize, format: format)
        return renderer.jpegData(withCompressionQuality: 0.9) { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: posterSize))
        }
    }

    /// 사진을 `size` 를 꽉 채우도록 받아 3:4 가운데를 남기고 JPEG 로 바꾼다.
    private static func jpegData(identifier: String, size: CGSize, quality: CGFloat) async -> Data? {
        guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil).firstObject else {
            return nil
        }
        let options = PHImageRequestOptions()
        // highQualityFormat 은 결과를 한 번만 준다. 두 번 주면 continuation 이 두 번 풀린다
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        return await withCheckedContinuation { continuation in
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: size,
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                let data = image.flatMap { centerCropped($0).jpegData(compressionQuality: quality) }
                continuation.resume(returning: data)
            }
        }
    }

    /// 3:4 가운데를 남긴다. 옆으로 누운 사진은 픽셀 기준 4:3 으로 자른다.
    private static func centerCropped(_ image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        let rotated: [UIImage.Orientation] = [.left, .right, .leftMirrored, .rightMirrored]
        let aspect: CGFloat = rotated.contains(image.imageOrientation) ? 4.0 / 3.0 : 3.0 / 4.0
        let cropWidth = min(width, height * aspect)
        let cropHeight = cropWidth / aspect
        let rect = CGRect(
            x: (width - cropWidth) / 2,
            y: (height - cropHeight) / 2,
            width: cropWidth,
            height: cropHeight
        ).integral
        guard let cropped = cgImage.cropping(to: rect) else { return image }
        return UIImage(cgImage: cropped, scale: 1, orientation: image.imageOrientation)
    }
}
