import Domain
import XCTest

final class PlaceClientTests: XCTestCase {
    func test_PlaceClient_testValue는_생성_가능() {
        // testValue 는 PlaceClient.swift 의 TestDependencyKey 확장이 선언한다.
        // @DependencyClient 는 미구현 클로저를 채운 init 을 제공한다.
        _ = PlaceClient.testValue
    }

    func test_PlaceClient_previewValue는_생성_가능() {
        _ = PlaceClient.previewValue
    }

    func test_previewValue_검색어가_이름에_들어간_장소만_돌려줌() async throws {
        let places = try await PlaceClient.previewValue.search(query: "서울숲")
        XCTAssertEqual(places.map(\.name), ["서울숲"])
    }

    func test_previewValue_지역목록은_비어있지_않음() async throws {
        let groups = try await PlaceClient.previewValue.regions()
        XCTAssertFalse(groups.isEmpty)
        XCTAssertTrue(groups.allSatisfy { !$0.regions.isEmpty })
    }
}
