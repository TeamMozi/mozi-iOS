import Foundation

/// 요청 하나에 붙는 task delegate. 보낸 바이트를 0~1 진행률로 바꿔 넘기고, 리디렉션은 따라가지 않는다.
final class UploadProgressDelegate: NSObject, URLSessionTaskDelegate, Sendable {
    private let onProgress: @Sendable (Double) -> Void

    init(onProgress: @escaping @Sendable (Double) -> Void) {
        self.onProgress = onProgress
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        onProgress(Self.fraction(sent: totalBytesSent, expected: totalBytesExpectedToSend))
    }

    /// 받은 주소로만 올린다. 3xx 를 따라가면 303 은 바디 없는 GET 이 되어도 성공으로 끝나므로, 3xx 를 그대로 돌려받아 `rejected` 로 처리한다.
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest
    ) async -> URLRequest? {
        nil
    }

    /// 전체 크기를 모르거나(음수) 0 이면 0 이다. 그 밖에는 0~1 로 자른다.
    static func fraction(sent: Int64, expected: Int64) -> Double {
        guard expected > 0 else { return 0 }
        return min(max(Double(sent) / Double(expected), 0), 1)
    }
}
