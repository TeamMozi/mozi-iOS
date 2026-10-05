import SwiftUI

/// 헤더·바텀시트 헤더 제목. 시스템 툴바의 `.principal` 자리나, 왼쪽 정렬이면 `.topBarLeading` 자리에 넣는다.
/// 왼쪽 정렬 자리에서는 `.fixedSize()` 와 `.sharedBackgroundVisibility(.hidden)` 을 함께 건다.
public struct DesignToolbarTitle: View {
    static let style = TextStyle.ds.headline.medium
    static let color = SemanticColor.text.neutral.primary

    private let title: String

    public init(_ title: String) {
        self.title = title
    }

    public var body: some View {
        Text(title)
            .font(Self.style.font)
            .kerning(Self.style.letterSpacing)
            .foregroundStyle(Self.color.color)
            .lineLimit(1)
    }
}

/// 헤더·바텀시트 헤더 버튼 안 아이콘. 시스템 툴바가 44pt 유리 원을 그리고, 이 아이콘은 그 안에 24pt 로 놓인다.
/// `Button { } label: { DesignToolbarIcon(Image.ds.icon.close.outlined) }` 꼴로 쓰고, 버튼에 읽기 이름을 단다.
public struct DesignToolbarIcon: View {
    static let size: CGFloat = CGFloat.ds.iconSize._24
    static let color = SemanticColor.text.neutral.primary

    private let image: Image

    public init(_ image: Image) {
        self.image = image
    }

    public var body: some View {
        image
            .iconSize(Self.size)
            .foregroundStyle(Self.color.color)
    }
}
