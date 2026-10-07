import Domain
import Foundation
import SharedLogger

enum PageDTOMapper {
    /// 항목 변환에 실패한 항목만 빼고 로그를 남긴다. 나머지 항목과 `next` 는 그대로다.
    static func domain<DTO: Decodable, Item>(
        from dto: PageResponseDTO<DTO>,
        item: (DTO) throws -> Item
    ) -> Page<Item> {
        var items: [Item] = []
        items.reserveCapacity(dto.content.count)
        for (index, element) in dto.content.enumerated() {
            do {
                items.append(try item(element))
            } catch {
                Logger.shared.warning(
                    "페이지 \(dto.number) 의 \(index)번 항목 변환 실패: \(error)",
                    category: .data
                )
            }
        }
        return Page(items: items, next: next(from: dto))
    }

    private static func next<DTO: Decodable>(from dto: PageResponseDTO<DTO>) -> PageRequest? {
        dto.last ? nil : PageRequest(page: dto.number + 1, size: dto.size)
    }
}
