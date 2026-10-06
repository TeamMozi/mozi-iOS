import Foundation

/// 업로드 주소 전용 업로더. 토큰 공급자·재발급기를 갖지 않아 `Authorization` 이 붙을 길이 없다.
public struct DefaultUploader: Uploading {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func upload(
        _ data: Data,
        to url: URL,
        contentType: String,
        onProgress: @escaping @Sendable (Double) -> Void
    ) async throws {
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.put.rawValue
        request.httpBody = data
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        NetworkLog.uploadRequest(url: url)

        let started = Date()
        let response: URLResponse
        do {
            (_, response) = try await session.data(
                for: request,
                delegate: UploadProgressDelegate(onProgress: onProgress)
            )
        } catch {
            // 취소(URLError.cancelled)도 여기로 온다. DefaultNetworkClient 와 같이 전송 실패로 묶는다.
            NetworkLog.error(error, url: url)
            throw UploadError.transport
        }

        let durationMs = Int(Date().timeIntervalSince(started) * 1000)
        guard let httpResponse = response as? HTTPURLResponse else {
            NetworkLog.uploadNonHTTPResponse(url: url)
            throw UploadError.transport
        }

        NetworkLog.uploadResponse(
            statusCode: httpResponse.statusCode,
            url: url,
            durationMs: durationMs
        )

        guard (200...299).contains(httpResponse.statusCode) else {
            throw UploadError.rejected(statusCode: httpResponse.statusCode)
        }
    }
}
