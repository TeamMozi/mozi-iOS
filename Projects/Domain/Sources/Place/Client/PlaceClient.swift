import Foundation
import ThirdParty

/// 장소 검색과 지역 목록을 다루는 Domain 포트.
@DependencyClient
public struct PlaceClient: Sendable {
    public var search: @Sendable (_ query: String) async throws -> [Place]
    public var regions: @Sendable () async throws -> [RegionGroup]
}

extension PlaceClient: TestDependencyKey {
    public static let testValue = PlaceClient()
    public static let previewValue = PlaceClient(
        search: { query in
            PlacePreviewData.places.filter { place in
                query.isEmpty || place.name.contains(query) || place.address.contains(query)
            }
        },
        regions: { PlacePreviewData.regionGroups }
    )
}

public extension DependencyValues {
    var placeClient: PlaceClient {
        get { self[PlaceClient.self] }
        set { self[PlaceClient.self] = newValue }
    }
}
