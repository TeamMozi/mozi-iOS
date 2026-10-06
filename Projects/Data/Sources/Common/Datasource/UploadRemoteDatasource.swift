import CoreNetwork
import Foundation

/// 업로드 주소로 바이트를 올리기만 한다. `UploadError` 를 바꾸지 않고 그대로 던진다.
/// 주소 발급·완료 통보는 기능 Remote 가, 발급 → 올리기 → 통보 순서는 기능 RepositoryImpl 이 맡는다.
struct UploadRemoteDatasource: Sendable {
    private let uploader: any Uploading

    init(uploader: any Uploading) {
        self.uploader = uploader
    }

    func upload(
        _ data: Data,
        to url: URL,
        contentType: String,
        onProgress: @escaping @Sendable (Double) -> Void = { _ in }
    ) async throws {
        try await uploader.upload(data, to: url, contentType: contentType, onProgress: onProgress)
    }
}
