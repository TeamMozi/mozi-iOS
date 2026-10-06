import Foundation

/// 업로드 주소로 바이트를 올리는 포트.
/// 받은 주소를 그대로 쓰고, 서버 주소를 붙이거나 인증 헤더를 넣지 않는다.
public protocol Uploading: Sendable {
    /// `onProgress` 는 보낸 바이트 기준 0~1 값을 받는다. 2xx 가 아니면 `UploadError` 를 던진다.
    func upload(
        _ data: Data,
        to url: URL,
        contentType: String,
        onProgress: @escaping @Sendable (Double) -> Void
    ) async throws
}
