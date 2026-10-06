import CoreNetwork
@testable import Data
import Foundation
import XCTest

final class PageResponseDTOTests: XCTestCase {
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

    func test_필수_칸이_하나라도_빠지면_그_칸을_찾지_못해_해석이_실패한다() throws {
        let complete: [String: Any] = [
            "content": [["id": 1, "kind": "photo"]],
            "number": 0,
            "size": 20,
            "last": true,
        ]

        for missing in ["content", "number", "size", "last"] {
            var json = complete
            json.removeValue(forKey: missing)
            let body = try JSONSerialization.data(withJSONObject: json)

            XCTAssertThrowsError(
                try NetworkJSONCoding.makeDecoder().decode(PageResponseDTO<TestItemDTO>.self, from: body),
                "missing \(missing)"
            ) { error in
                guard case let DecodingError.keyNotFound(key, _) = error else {
                    return XCTFail("missing \(missing) unexpected \(error)")
                }
                XCTAssertEqual(key.stringValue, missing)
            }
        }
    }

    func test_number가_Int_max면_해석이_실패한다() {
        let body = Data(#"{"content":[],"number":9223372036854775807,"size":20,"last":false}"#.utf8)

        XCTAssertThrowsError(
            try NetworkJSONCoding.makeDecoder().decode(PageResponseDTO<TestItemDTO>.self, from: body)
        ) { error in
            guard case DecodingError.dataCorrupted = error else {
                return XCTFail("unexpected \(error)")
            }
        }
    }
}
