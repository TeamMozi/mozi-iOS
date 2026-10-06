import Foundation

/// 서버 `Page*Response` 의 공통 꼴. 네 칸만 읽고 나머지 칸은 무시한다.
/// 네 칸 중 하나라도 빠지거나 `number` 가 `Int.max` 이면(다음 페이지 번호를 만들 수 없다) 해석이 실패한다(`NetworkError.decodingFailed`).
struct PageResponseDTO<Item: Decodable>: Decodable {
    let content: [Item]
    let number: Int
    let size: Int
    let last: Bool
}

extension PageResponseDTO {
    private enum CodingKeys: String, CodingKey {
        case content, number, size, last
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let number = try container.decode(Int.self, forKey: .number)
        guard number < Int.max else {
            throw DecodingError.dataCorruptedError(forKey: .number, in: container, debugDescription: "number 범위 밖")
        }
        self.init(
            content: try container.decode([Item].self, forKey: .content),
            number: number,
            size: try container.decode(Int.self, forKey: .size),
            last: try container.decode(Bool.self, forKey: .last)
        )
    }
}

extension PageResponseDTO: Sendable where Item: Sendable {}
extension PageResponseDTO: Equatable where Item: Equatable {}
