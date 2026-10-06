@testable import CoreNetwork
import XCTest

final class UploadProgressDelegateTests: XCTestCase {
    func test_보낸_바이트와_전체_바이트로_0에서_1_사이_진행률을_넘긴다() throws {
        let recorder = ProgressRecorder()
        let delegate = UploadProgressDelegate(onProgress: { recorder.append($0) })
        let session = URLSession(configuration: .ephemeral)
        defer { session.invalidateAndCancel() }
        let url = try XCTUnwrap(URL(string: "https://storage.example.invalid/upload"))
        let task = session.dataTask(with: url)

        for (sent, total) in [(Int64(0), Int64(200)), (50, 200), (200, 200)] {
            delegate.urlSession(
                session,
                task: task,
                didSendBodyData: sent,
                totalBytesSent: sent,
                totalBytesExpectedToSend: total
            )
        }

        XCTAssertEqual(recorder.values, [0, 0.25, 1])
    }

    func test_전체_바이트가_0_이하면_진행률은_0() {
        XCTAssertEqual(UploadProgressDelegate.fraction(sent: 10, expected: 0), 0)
        XCTAssertEqual(UploadProgressDelegate.fraction(sent: 10, expected: -1), 0)
    }

    func test_보낸_바이트가_전체를_넘으면_진행률은_1() {
        XCTAssertEqual(UploadProgressDelegate.fraction(sent: 300, expected: 200), 1)
    }

    func test_리디렉션은_따라가지_않는다() async throws {
        let delegate = UploadProgressDelegate(onProgress: { _ in })
        let session = URLSession(configuration: .ephemeral)
        defer { session.invalidateAndCancel() }
        let url = try XCTUnwrap(URL(string: "https://storage.example.invalid/upload"))
        let redirectURL = try XCTUnwrap(URL(string: "https://other.example.invalid/x"))
        let task = session.dataTask(with: url)
        let response = try XCTUnwrap(
            HTTPURLResponse(
                url: url,
                statusCode: 303,
                httpVersion: nil,
                headerFields: ["Location": redirectURL.absoluteString]
            )
        )

        let next = await delegate.urlSession(
            session,
            task: task,
            willPerformHTTPRedirection: response,
            newRequest: URLRequest(url: redirectURL)
        )

        XCTAssertNil(next)
    }
}

private final class ProgressRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private var stored: [Double] = []

    var values: [Double] {
        lock.lock()
        defer { lock.unlock() }
        return stored
    }

    func append(_ value: Double) {
        lock.lock()
        defer { lock.unlock() }
        stored.append(value)
    }
}
