import Foundation

/// 지역 목록의 시·도 묶음.
public struct RegionGroup: Equatable, Sendable {
    /// 시·도 줄임 이름 (예: 서울)
    public var provinceShortName: String?
    public var regions: [Region]

    public init(
        provinceShortName: String?,
        regions: [Region]
    ) {
        self.provinceShortName = provinceShortName
        self.regions = regions
    }
}
