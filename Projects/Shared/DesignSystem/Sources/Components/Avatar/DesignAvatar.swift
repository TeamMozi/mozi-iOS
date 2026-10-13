import SwiftUI

/// 프로필 사진 모양. 기본은 원이다.
public enum DesignAvatarShape: Sendable, Equatable {
    case circle
    /// 모서리가 둥근 사각형. 반지름은 `CGFloat.ds.radius` 토큰을 넘긴다.
    case roundedRectangle(cornerRadius: CGFloat)
}

/// 프로필 사진. 사진이 없거나 읽는 중이면 바탕색으로 칠한다. 한 변 길이와 모양은 쓰는 화면이 정한다.
/// 장식이라 VoiceOver 가 읽지 않는다. 이름은 옆 글자가 읽는다.
public struct DesignAvatar: View {
    private let url: URL?
    private let diameter: CGFloat
    private let shape: DesignAvatarShape

    public init(_ url: URL?, diameter: CGFloat, shape: DesignAvatarShape = .circle) {
        self.url = url
        self.diameter = diameter
        self.shape = shape
    }

    public var body: some View {
        AsyncImage(url: url) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                DesignAvatarMetrics.placeholder.color
            }
        }
        .frame(width: diameter, height: diameter)
        .clipShape(DesignAvatarMetrics.clipShape(for: shape))
        .accessibilityHidden(true)
    }
}

enum DesignAvatarMetrics {
    static let placeholder = SemanticColor.fill.neutral.subtle

    static func clipShape(for shape: DesignAvatarShape) -> AnyShape {
        switch shape {
        case .circle:
            AnyShape(Circle())
        case let .roundedRectangle(cornerRadius):
            AnyShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
    }
}
