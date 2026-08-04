import CoreNetwork
import XCTest

final class NetworkErrorMappingTests: XCTestCase {
    override func tearDown() {
        URLProtocolStub.reset()
        super.tearDown()
    }

    func test_statusCodeMapping() async {
        let cases: [(Int, NetworkError)] = [
            (400, .badRequest(message: "bad")),
            (401, .unauthorized),
            (403, .forbidden(message: "no")),
            (404, .notFound(message: "missing")),
            (409, .conflict(message: "dup")),
            (500, .serverError(statusCode: 500, message: "boom")),
        ]

        for (status, expected) in cases {
            URLProtocolStub.reset()
            let message = expectedMessage(for: expected)
            URLProtocolStub.requestHandler = { _ in
                let data = Data(#"{"message":"\#(message)"}"#.utf8)
                return .init(statusCode: status, headers: [:], data: data)
            }
            guard let baseURL = URL(string: "https://api.example.invalid") else {
                XCTFail("invalid base URL")
                return
            }
            let client = DefaultNetworkClient.plain(
                configuration: NetworkConfiguration(baseURL: baseURL),
                session: TestSessionFactory.make()
            )
            do {
                let _: Dummy = try await client.request(TestEndpoint())
                XCTFail("status \(status) should fail")
            } catch let error as NetworkError {
                XCTAssertEqual(error, expected, "status \(status)")
            } catch {
                XCTFail("status \(status) unexpected \(error)")
            }
        }
    }

    private struct Dummy: Decodable { let value: Int }

    private func expectedMessage(for error: NetworkError) -> String {
        switch error {
        case let .badRequest(message),
             let .forbidden(message),
             let .notFound(message),
             let .conflict(message),
             let .serverError(_, message):
            return message ?? ""
        case .unauthorized:
            return "unauthorized"
        default:
            return ""
        }
    }
}
