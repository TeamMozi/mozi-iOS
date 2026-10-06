import Foundation

/// 모임이 주로 열리는 지역. `id` 는 서버가 주는 법정동코드다.
public struct Region: Equatable, Sendable {
    public var id: String
    /// 시·도 (예: 서울특별시)
    public var province: String
    /// 시·군·구 (예: 중랑구). 시·도에 시·군·구가 없으면 비어 있다.
    public var district: String?

    public init(
        id: String,
        province: String,
        district: String?
    ) {
        self.id = id
        self.province = province
        self.district = district
    }
}
