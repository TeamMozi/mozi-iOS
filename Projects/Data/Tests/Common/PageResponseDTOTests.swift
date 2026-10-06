import CoreNetwork
@testable import Data
import Foundation
import XCTest

final class PageResponseDTOTests: XCTestCase {
    override func setUp() {
        super.setUp()
        AuthURLProtocolStub.reset()
    }

    override func tearDown() {
        AuthURLProtocolStub.reset()
        super.tearDown()
    }

    func test_네_칸이_있으면_나머지_칸은_읽지_않고_해석한다() throws {
        let json = Data(
            #"""
            {
              "content": [{ "id": 1, "kind": "photo" }],
              "pageable": { "pageNumber": 0, "pageSize": 20, "sort": { "sorted": false } },
              "totalElements": 1,
              "totalPages": 1,
              "number": 0,
              "size": 20,
              "last": true,
              "first": true,
              "numberOfElements": 1,
              "empty": false
            }
            """#.utf8
        )

        let dto = try NetworkJSONCoding.makeDecoder().decode(PageResponseDTO<TestItemDTO>.self, from: json)

        XCTAssertEqual(
            dto,
            PageResponseDTO(content: [TestItemDTO(id: 1, kind: "photo")], number: 0, size: 20, last: true)
        )
    }

    func test_필수_칸이_하나라도_빠지면_decodingFailed() async throws {
        let complete: [String: Any] = [
            "content": [["id": 1, "kind": "photo"]],
            "number": 0,
            "size": 20,
            "last": true,
        ]
        let baseURL = try XCTUnwrap(URL(string: "https://api.example.invalid"))

        for missing in ["content", "number", "size", "last"] {
            var json = complete
            json.removeValue(forKey: missing)
            let body = try JSONSerialization.data(withJSONObject: json)
            AuthURLProtocolStub.reset()
            AuthURLProtocolStub.requestHandler = { _ in
                .init(statusCode: 200, headers: [:], data: body)
            }
            let client = DefaultNetworkClient.plain(
                configuration: NetworkConfiguration(baseURL: baseURL),
                session: AuthTestSessionFactory.make()
            )

            do {
                let _: PageResponseDTO<TestItemDTO> = try await client.request(PageTestEndpoint())
                XCTFail("missing \(missing) should fail")
            } catch let error as NetworkError {
                XCTAssertEqual(error, .decodingFailed, "missing \(missing)")
            } catch {
                XCTFail("missing \(missing) unexpected \(error)")
            }
        }
    }
}
