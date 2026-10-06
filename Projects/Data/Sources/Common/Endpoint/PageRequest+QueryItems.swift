import Domain
import Foundation

extension PageRequest {
    /// 서버 쿼리 `page`·`size` 로 펼친다. 정렬은 넣지 않는다.
    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "size", value: String(size)),
        ]
    }
}
