import Foundation

struct DevLoginRequestDTO: Encodable, Sendable {
    // 서버 계약이 빈 body 또는 고정 payload 면 그에 맞춤.
    // OpenAPI 확인 불가 시 빈 object `{}` 로 보낸다.
}
