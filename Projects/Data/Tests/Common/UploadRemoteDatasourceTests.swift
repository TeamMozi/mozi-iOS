import CoreNetwork
@testable import Data
import Foundation
import XCTest

final class UploadRemoteDatasourceTests: XCTestCase {
    // onProgress 를 넘기지 않는다. 기본값 { _ in } 이 있어야 컴파일된다.
    func test_바이트와_주소와_형식을_업로더에_그대로_넘긴다() async throws {
        let uploader = FakeUploader()
        let sut = UploadRemoteDatasource(uploader: uploader)
        let url = try XCTUnwrap(URL(string: "https://storage.example.invalid/snaps/1?token=abc"))
        let bytes = Data("photo".utf8)

        try await sut.upload(bytes, to: url, contentType: "image/jpeg")

        let sent = await uploader.sentUploads
        XCTAssertEqual(
            sent,
            [FakeUploader.SentUpload(data: bytes, url: url, contentType: "image/jpeg")]
        )
    }

    func test_업로더가_넘긴_진행률을_차례대로_전한다() async throws {
        let uploader = FakeUploader(progressValues: [0, 0.5, 1])
        let sut = UploadRemoteDatasource(uploader: uploader)
        let recorder = ProgressRecorder()
        let url = try XCTUnwrap(URL(string: "https://storage.example.invalid/snaps/1?token=abc"))

        try await sut.upload(
            Data("photo".utf8),
            to: url,
            contentType: "image/jpeg",
            onProgress: { recorder.append($0) }
        )

        XCTAssertEqual(recorder.values, [0, 0.5, 1])
    }

    func test_업로드_거부를_바꾸지_않고_그대로_던진다() async throws {
        let sut = UploadRemoteDatasource(uploader: FakeUploader(error: UploadError.rejected(statusCode: 403)))
        let url = try XCTUnwrap(URL(string: "https://storage.example.invalid/snaps/1?token=abc"))

        do {
            try await sut.upload(Data("photo".utf8), to: url, contentType: "image/jpeg")
            XCTFail("오류가 나야 한다")
        } catch let error as UploadError {
            XCTAssertEqual(error, .rejected(statusCode: 403))
        } catch {
            XCTFail("UploadError 가 아니다: \(error)")
        }
    }

    func test_업로드_전송_실패를_바꾸지_않고_그대로_던진다() async throws {
        let sut = UploadRemoteDatasource(uploader: FakeUploader(error: UploadError.transport))
        let url = try XCTUnwrap(URL(string: "https://storage.example.invalid/snaps/1?token=abc"))

        do {
            try await sut.upload(Data("photo".utf8), to: url, contentType: "image/jpeg")
            XCTFail("오류가 나야 한다")
        } catch let error as UploadError {
            XCTAssertEqual(error, .transport)
        } catch {
            XCTFail("UploadError 가 아니다: \(error)")
        }
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
