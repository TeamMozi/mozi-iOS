import CoreNetwork
import Foundation

/// Data 테스트용 `Uploading`. 받은 인자를 기록하고, 미리 넣은 진행률을 차례로 넘긴 뒤 미리 넣은 오류를 던진다.
/// 실제 전송과 상태 코드 → `UploadError` 변환은 하지 않는다. 그 검증은 CoreNetwork 테스트가 맡는다.
actor FakeUploader: Uploading {
    struct SentUpload: Equatable, Sendable {
        let data: Data
        let url: URL
        let contentType: String
    }

    private(set) var sentUploads: [SentUpload] = []
    private let progressValues: [Double]
    private let error: (any Error)?

    /// `progressValues` 를 `onProgress` 로 차례로 넘긴다. `error` 가 있으면 그 뒤에 던진다.
    init(progressValues: [Double] = [], error: (any Error)? = nil) {
        self.progressValues = progressValues
        self.error = error
    }

    func upload(
        _ data: Data,
        to url: URL,
        contentType: String,
        onProgress: @escaping @Sendable (Double) -> Void
    ) async throws {
        sentUploads.append(SentUpload(data: data, url: url, contentType: contentType))
        for value in progressValues {
            onProgress(value)
        }
        if let error {
            throw error
        }
    }
}
