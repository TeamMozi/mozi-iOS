@testable import Data
import Domain
import XCTest

final class PageDTOMapperTests: XCTestCase {
    func test_중간_페이지면_next가_다음_페이지_번호와_같은_크기() {
        let dto = PageResponseDTO(
            content: [TestItemDTO(id: 1, kind: "photo"), TestItemDTO(id: 2, kind: "video")],
            number: 1,
            size: 20,
            last: false
        )

        let page = PageDTOMapper.domain(from: dto, item: TestItemMapper.domain(from:))

        XCTAssertEqual(
            page,
            Page(
                items: [TestItem(id: 1, kind: .photo), TestItem(id: 2, kind: .video)],
                next: PageRequest(page: 2, size: 20)
            )
        )
    }

    func test_마지막_페이지면_next가_nil() {
        let dto = PageResponseDTO(
            content: [TestItemDTO(id: 9, kind: "photo")],
            number: 4,
            size: 20,
            last: true
        )

        let page = PageDTOMapper.domain(from: dto, item: TestItemMapper.domain(from:))

        XCTAssertEqual(page.items, [TestItem(id: 9, kind: .photo)])
        XCTAssertNil(page.next)
    }

    func test_변환에_실패한_항목만_빠지고_나머지와_next는_그대로() {
        let dto = PageResponseDTO(
            content: [
                TestItemDTO(id: 1, kind: "photo"),
                TestItemDTO(id: 2, kind: "sticker"),
                TestItemDTO(id: 3, kind: "video"),
            ],
            number: 0,
            size: 20,
            last: false
        )

        let page = PageDTOMapper.domain(from: dto, item: TestItemMapper.domain(from:))

        XCTAssertEqual(page.items, [TestItem(id: 1, kind: .photo), TestItem(id: 3, kind: .video)])
        XCTAssertEqual(page.next, PageRequest(page: 1, size: 20))
    }

    func test_빈_페이지여도_last가_false면_next를_만든다() {
        let dto = PageResponseDTO<TestItemDTO>(content: [], number: 3, size: 20, last: false)

        let page = PageDTOMapper.domain(from: dto, item: TestItemMapper.domain(from:))

        XCTAssertEqual(page, Page(items: [], next: PageRequest(page: 4, size: 20)))
    }
}
