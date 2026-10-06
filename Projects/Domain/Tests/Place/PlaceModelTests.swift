import Domain
import XCTest

final class PlaceModelTests: XCTestCase {
    func test_장소_칸이_같으면_같은_장소() {
        let a = Place(name: "서울숲", address: "서울 성동구 뚝섬로 273", latitude: 37.5444, longitude: 127.0374)
        let b = Place(name: "서울숲", address: "서울 성동구 뚝섬로 273", latitude: 37.5444, longitude: 127.0374)
        XCTAssertEqual(a, b)
    }

    func test_지역묶음_칸이_같으면_같은_묶음() {
        let region = Region(id: "1126000000", province: "서울특별시", district: "중랑구")
        XCTAssertEqual(
            RegionGroup(provinceShortName: "서울", regions: [region]),
            RegionGroup(provinceShortName: "서울", regions: [region])
        )
        XCTAssertNotEqual(region, Region(id: "1126000000", province: "서울특별시", district: nil))
    }

    func test_장소에러_메시지가_다르면_다른_에러() {
        XCTAssertEqual(PlaceError.unknown(message: "a"), PlaceError.unknown(message: "a"))
        XCTAssertNotEqual(PlaceError.unknown(message: "a"), PlaceError.unknown(message: "b"))
    }
}
