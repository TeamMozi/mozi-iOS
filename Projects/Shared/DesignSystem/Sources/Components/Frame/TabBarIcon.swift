import SwiftUI
import UIKit

/// 시스템 탭바(`TabView`) 아이콘 다섯. `.tabItem { }` 안에 `image(isSelected:colorScheme:)` 를 넣는다.
/// 선택된 탭은 채움 모양, 나머지는 선 모양이다. 「+」 는 늘 채움 모양이다.
/// 색을 그림에 입혀 원본으로 그리므로 시스템 선택 색에 덮이지 않고, 탭 안 화면의 강조색도 건드리지 않는다.
public enum TabBarIcon: CaseIterable, Sendable {
    case playStack
    case search
    case chat
    case person
    case plus

    /// 모드마다 색이 달라 화면의 `colorScheme` 을 받는다. 모드가 바뀌면 화면이 다시 그리며 새 그림을 받는다.
    @MainActor
    public func image(isSelected: Bool, colorScheme: ColorScheme) -> Image {
        Image(uiImage: uiImage(isSelected: isSelected, style: Self.style(for: colorScheme)))
    }

    /// 그림 한 변. Figma 탭 아이콘 28.
    static let side: CGFloat = CGFloat.ds.iconSize._28

    static func style(for colorScheme: ColorScheme) -> UIUserInterfaceStyle {
        colorScheme == .light ? .light : .dark
    }

    func asset(isSelected: Bool) -> SharedDesignSystemImages {
        let filled = isSelected || self == .plus
        switch self {
        case .playStack:
            return filled ? SharedDesignSystemAsset.iconPlayStackFilled : SharedDesignSystemAsset.iconPlayStackOutlined
        case .search:
            return filled ? SharedDesignSystemAsset.iconSearchFilled : SharedDesignSystemAsset.iconSearchOutlined
        case .chat:
            return filled ? SharedDesignSystemAsset.iconChatFilled : SharedDesignSystemAsset.iconChatOutlined
        case .person:
            return filled ? SharedDesignSystemAsset.iconPersonFilled : SharedDesignSystemAsset.iconPersonOutlined
        case .plus:
            return SharedDesignSystemAsset.iconPlusFilled
        }
    }

    var theme: ThemedColor {
        self == .plus ? SemanticColor.text.accent.default : SemanticColor.text.neutral.primary
    }

    // 템플릿 그림을 그린 뒤 그 모양 안만 색으로 채운다(`.sourceIn`). SwiftUI `.renderingMode(.original)` 은
    // 시스템 탭바 색에 덮인다(2026-10-05 실험).
    @MainActor
    func uiImage(isSelected: Bool, style: UIUserInterfaceStyle) -> UIImage {
        let color = theme.resolved(for: style).uiColor
        let template = asset(isSelected: isSelected).image
        let rect = CGRect(x: 0, y: 0, width: Self.side, height: Self.side)
        let format = UIGraphicsImageRendererFormat.preferred()
        format.preferredRange = .standard
        let drawn = UIGraphicsImageRenderer(size: rect.size, format: format).image { context in
            template.draw(in: rect)
            color.setFill()
            context.fill(rect, blendMode: .sourceIn)
        }
        return drawn.withRenderingMode(.alwaysOriginal)
    }
}
