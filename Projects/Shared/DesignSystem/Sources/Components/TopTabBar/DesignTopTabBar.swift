import SwiftUI

/// 화면 위 글자 탭. 탭마다 가로를 똑같이 나누고, 고른 탭 아래에 선을 긋는다. 맨 아래에 옅은 구분선이 깔린다.
/// 고른 탭은 쓰는 쪽이 들고, 누르면 `onSelect` 가 불린다.
public struct DesignTopTabBar<Tab: Hashable>: View {
    private let tabs: [Tab]
    private let selection: Tab
    private let title: (Tab) -> String
    private let onSelect: @MainActor (Tab) -> Void

    public init(
        _ tabs: [Tab],
        selection: Tab,
        title: @escaping (Tab) -> String,
        onSelect: @escaping @MainActor (Tab) -> Void
    ) {
        self.tabs = tabs
        self.selection = selection
        self.title = title
        self.onSelect = onSelect
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.self) { tab in
                item(tab, isSelected: tab == selection)
            }
        }
        .padding(.horizontal, DesignTopTabBarMetrics.horizontalPadding)
        .overlay(alignment: .bottom) {
            DesignTopTabBarStyleResolver.divider.color
                .frame(height: DesignTopTabBarMetrics.dividerHeight)
        }
    }

    private func item(_ tab: Tab, isSelected: Bool) -> some View {
        Button {
            onSelect(tab)
        } label: {
            VStack(spacing: DesignTopTabBarMetrics.titleToIndicatorSpacing) {
                DesignText(
                    title(tab),
                    style: DesignTopTabBarMetrics.titleStyle,
                    color: DesignTopTabBarStyleResolver.title(isSelected: isSelected).color,
                    alignment: .center,
                    lineLimit: 1
                )
                (isSelected ? DesignTopTabBarStyleResolver.indicator.color : Color.clear)
                    .frame(height: DesignTopTabBarMetrics.indicatorHeight)
            }
            .padding(.top, DesignTopTabBarMetrics.titleTopPadding)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// 시안 `2798:104700` 탭 영역(`taps` col=3, `tap` Active·Inactive) 값.
/// 시안은 높이 48 탭 가운데에 글자를 두고 아래 테두리 2 로 선을 긋는다. 위 13 + 글자 22 + 11 + 선 2 = 48 로 옮겼다.
enum DesignTopTabBarMetrics {
    static let titleStyle: TextStyle = TextStyle.ds.headline.medium
    static let titleTopPadding: CGFloat = 13
    static let titleToIndicatorSpacing: CGFloat = 11
    static let indicatorHeight: CGFloat = CGFloat.ds.border.thick
    static let dividerHeight: CGFloat = 0.8
    static let horizontalPadding: CGFloat = CGFloat.ds.layout.margin
}

enum DesignTopTabBarStyleResolver {
    static func title(isSelected: Bool) -> ThemedColor {
        isSelected ? SemanticColor.text.neutral.primary : SemanticColor.text.neutral.subtle
    }

    static let indicator: ThemedColor = SemanticColor.text.neutral.primary
    static let divider: ThemedColor = SemanticColor.fill.neutral.strong
}
