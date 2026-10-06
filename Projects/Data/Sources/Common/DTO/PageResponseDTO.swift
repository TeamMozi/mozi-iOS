import Foundation

/// 서버 `Page*Response` 의 공통 꼴. 네 칸만 읽고 나머지 칸은 무시한다.
/// 네 칸 중 하나라도 빠지면 해석이 실패한다(`NetworkError.decodingFailed`).
struct PageResponseDTO<Item: Decodable>: Decodable {
    let content: [Item]
    let number: Int
    let size: Int
    let last: Bool
}

extension PageResponseDTO: Sendable where Item: Sendable {}
extension PageResponseDTO: Equatable where Item: Equatable {}
