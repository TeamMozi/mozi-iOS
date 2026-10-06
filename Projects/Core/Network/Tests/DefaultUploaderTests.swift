@testable import CoreNetwork
import XCTest

final class DefaultUploaderTests: XCTestCase {
    override func tearDown() {
        URLProtocolStub.reset()
        super.tearDown()
    }

    func test_업로드는_받은_주소로_PUT과_Content_Type과_바이트를_보내고_Authorization은_없다() async throws {
        URLProtocolStub.requestHandler = { _ in
            .init(statusCode: 200, headers: [:], data: Data())
        }
        let url = try XCTUnwrap(
            URL(string: "https://storage.example.invalid/object/upload/sign/profile/1.jpg?token=signed")
        )
        let bytes = Data([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10])
        let uploader = DefaultUploader(session: TestSessionFactory.make())

        try await uploader.upload(bytes, to: url, contentType: "image/jpeg", onProgress: { _ in })

        XCTAssertEqual(URLProtocolStub.requests.count, 1)
        let request = try XCTUnwrap(URLProtocolStub.requests.first)
        XCTAssertEqual(request.httpMethod, "PUT")
        XCTAssertEqual(request.url, url)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "image/jpeg")
        XCTAssertEqual(request.httpBody, bytes)
        XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"))
    }

    func test_업로드_응답이_2xx면_성공한다() async throws {
        let url = try XCTUnwrap(URL(string: "https://storage.example.invalid/upload?token=signed"))
        for status in [200, 201, 204] {
            URLProtocolStub.reset()
            URLProtocolStub.requestHandler = { _ in
                .init(statusCode: status, headers: [:], data: Data())
            }
            let uploader = DefaultUploader(session: TestSessionFactory.make())

            try await uploader.upload(Data([0x01]), to: url, contentType: "image/png", onProgress: { _ in })
        }
    }

    func test_업로드_응답이_4xx나_5xx면_rejected로_상태코드를_보존한다() async throws {
        let url = try XCTUnwrap(URL(string: "https://storage.example.invalid/upload?token=signed"))
        for status in [400, 401, 403, 404, 500, 503] {
            URLProtocolStub.reset()
            URLProtocolStub.requestHandler = { _ in
                .init(statusCode: status, headers: [:], data: Data(#"{"message":"denied"}"#.utf8))
            }
            let uploader = DefaultUploader(session: TestSessionFactory.make())

            do {
                try await uploader.upload(Data([0x01]), to: url, contentType: "image/png", onProgress: { _ in })
                XCTFail("status \(status) should fail")
            } catch let error as UploadError {
                XCTAssertEqual(error, .rejected(statusCode: status), "status \(status)")
            } catch {
                XCTFail("status \(status) unexpected \(error)")
            }
        }
    }

    func test_망_오류면_transport() async throws {
        URLProtocolStub.requestHandler = { _ in
            throw URLError(.notConnectedToInternet)
        }
        let url = try XCTUnwrap(URL(string: "https://storage.example.invalid/upload?token=signed"))
        let uploader = DefaultUploader(session: TestSessionFactory.make())

        do {
            try await uploader.upload(Data([0x01]), to: url, contentType: "image/png", onProgress: { _ in })
            XCTFail("expected transport")
        } catch let error as UploadError {
            XCTAssertEqual(error, .transport)
        } catch {
            XCTFail("unexpected \(error)")
        }
    }
}
