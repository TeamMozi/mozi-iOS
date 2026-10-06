import Foundation

/// 요청 하나에 붙는 task delegate. 보낸 바이트를 0~1 진행률로 바꿔 넘긴다.
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

    /// 전체 크기를 모르거나(음수) 0 이면 0 이다. 그 밖에는 0~1 로 자른다.
    static func fraction(sent: Int64, expected: Int64) -> Double {
        guard expected > 0 else { return 0 }
        return min(max(Double(sent) / Double(expected), 0), 1)
    }
}
