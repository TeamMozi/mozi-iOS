import Foundation

struct TestItemDTO: Decodable, Equatable, Sendable {
    let id: Int
    let kind: String
}

struct TestItem: Equatable {
    let id: Int
    let kind: TestItemKind
}

enum TestItemKind: String {
    case photo
    case video
}

enum TestItemMappingError: Error {
    case unknownKind(String)
}

enum TestItemMapper {
    static func domain(from dto: TestItemDTO) throws -> TestItem {
        guard let kind = TestItemKind(rawValue: dto.kind) else {
            throw TestItemMappingError.unknownKind(dto.kind)
        }
        return TestItem(id: dto.id, kind: kind)
    }
}
