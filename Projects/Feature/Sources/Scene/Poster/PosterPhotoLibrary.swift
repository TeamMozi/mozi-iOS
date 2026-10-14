import Foundation
import ThirdParty

/// 포스터 사진 고르기에 쓰는 사진 보관함. PhotoKit 을 감싼 Feature 안 의존이다.
/// 화면이 PhotoKit 을 바로 부르지 않고 이 의존을 거쳐, 리듀서 테스트가 권한 거부와 사진 읽기를 가짜로 바꾼다.
@DependencyClient
public struct PosterPhotoLibrary: Sendable {
    /// 사진 보관함 권한. 정해지지 않았으면 묻고, 정해졌으면 묻지 않고 지금 상태를 돌려준다.
    public var requestAccess: @Sendable () async -> PhotoLibraryAccess = { .denied }
    /// 최근 사진 `limit` 장의 작은 그림. 최신부터다.
    public var recentPhotos: @Sendable (_ limit: Int) async throws -> [PhotoLibraryItem]
    /// 고른 사진을 3:4 가운데로 잘라 JPEG 로 돌려준다.
    public var posterData: @Sendable (_ id: String) async throws -> Data
    /// 「기본」 단색 견본 `index` 를 3:4 JPEG 로 돌려준다.
    public var swatchData: @Sendable (_ index: Int) async throws -> Data
}

public enum PhotoLibraryAccess: Equatable, Sendable {
    case authorized
    /// 일부 사진만 허용했다
    case limited
    /// 거부했거나 제한됐다
    case denied
}

public struct PhotoLibraryItem: Equatable, Identifiable, Sendable {
    public var id: String
    /// 격자에 그리는 작은 3:4 JPEG
    public var thumbnail: Data

    public init(id: String, thumbnail: Data) {
        self.id = id
        self.thumbnail = thumbnail
    }
}

public enum PhotoLibraryError: Error, Equatable, Sendable {
    case notFound
    case unreadable
}

extension PosterPhotoLibrary: TestDependencyKey {
    public static let testValue = PosterPhotoLibrary()
}

public extension DependencyValues {
    var posterPhotoLibrary: PosterPhotoLibrary {
        get { self[PosterPhotoLibrary.self] }
        set { self[PosterPhotoLibrary.self] = newValue }
    }
}
