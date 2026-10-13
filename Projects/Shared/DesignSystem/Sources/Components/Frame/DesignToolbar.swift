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
    /// 강조 유리 원 위 아이콘. 시안 Header Btn accent 는 모드와 상관없이 검정이다
    static let prominentColor = ThemedColor.fixed(PrimitiveColor.neutral._1300)

    @Environment(\.isEnabled) private var isEnabled
    private let image: Image
    private let isProminent: Bool

    /// - Parameter isProminent: 버튼에 `.designToolbarProminent()` 를 걸었으면 `true`. 켜진 동안 아이콘을 검정으로 그린다.
    public init(_ image: Image, isProminent: Bool = false) {
        self.image = image
        self.isProminent = isProminent
    }

    public var body: some View {
        image
            .iconSize(Self.size)
            .foregroundStyle((isProminent && isEnabled ? Self.prominentColor : Self.color).color)
    }
}

/// 헤더 오른쪽 확인 버튼(→·체크)의 강조 모양. 시안 Header Btn accent 처럼 켜지면 강조색 유리 원, 꺼지면 시스템 회색 유리 원이다.
/// `Button { } label: { DesignToolbarIcon(Image.ds.icon.arrows.right, isProminent: true) }.designToolbarProminent()` 꼴로 쓴다.
public extension View {
    func designToolbarProminent() -> some View {
        buttonStyle(.glassProminent)
            .tint(DesignToolbarProminent.tint.color)
    }
}

enum DesignToolbarProminent {
    /// 시안 Header Btn accent 바탕 `text/accent/highlight`
    static let tint = SemanticColor.text.accent.highlight
}
