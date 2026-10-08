import Foundation
import ThirdParty

/// 카테고리 목록을 다루는 Domain 포트. 목록의 주인은 서버다.
@DependencyClient
public struct InterestClient: Sendable {
    /// 서버가 준 순서 그대로 돌려준다.
    public var interests: @Sendable () async throws -> [Interest]
}

extension InterestClient: TestDependencyKey {
    public static let testValue = InterestClient()
    public static let previewValue = InterestClient(
        interests: { InterestPreviewData.all }
    )
}

public extension InterestClient {
    /// `previewValue` 가 돌려주는 목록. 시안 12개 이름이고 격자 순서다.
    static let previewInterests: [Interest] = InterestPreviewData.all
}

public extension DependencyValues {
    var interestClient: InterestClient {
        get { self[InterestClient.self] }
        set { self[InterestClient.self] = newValue }
    }
}
