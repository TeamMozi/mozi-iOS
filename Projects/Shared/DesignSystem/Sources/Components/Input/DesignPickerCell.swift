import SwiftUI

/// 고르기 칸 하나(시안 Row chips 의 Picker 칸). 채움 없이 테두리만 있고, 칸 위 라벨이 없다.
/// 칸을 누르면 `options` 메뉴가 뜨고, 고르면 `onSelect` 가 불린다. 지금 값은 쓰는 쪽이 넘긴다.
/// 가로는 남는 폭을 채운다. 두 칸을 나란히 두면 반씩 나눈다.
public struct DesignPickerCell: View {
    private let value: String?
    private let placeholder: String
    private let options: [String]
    private let onSelect: @MainActor (String) -> Void

    public init(
        value: String?,
        placeholder: String,
        options: [String],
        onSelect: @escaping @MainActor (String) -> Void
    ) {
        self.value = value
        self.placeholder = placeholder
        self.options = options
        self.onSelect = onSelect
    }

    public var body: some View {
        Menu {
            DesignMenuOptions(options: options, selected: value, title: { $0 }, onSelect: onSelect)
        } label: {
            DesignPickerCellBox(value: value, placeholder: placeholder)
        }
        .menuIndicator(.hidden)
        .accessibilityLabel(placeholder)
        .accessibilityValue(value ?? "")
        .accessibilityAddTraits(.isButton)
    }
}

/// 고르기 칸의 겉모양. 메뉴 없이 그림만 그릴 때(미리보기·렌더 대조)도 쓴다.
struct DesignPickerCellBox: View {
    let value: String?
    let placeholder: String

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: DesignPickerCellMetrics.cornerRadius)
        return HStack(spacing: DesignPickerCellMetrics.contentSpacing) {
            DesignText(
                value ?? placeholder,
                style: DesignPickerCellMetrics.textStyle,
                color: DesignPickerCellPalette.text(isEmpty: value == nil).color,
                lineLimit: 1
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            Image.ds.icon.chevron.down
                .iconSize(DesignPickerCellMetrics.chevronSize)
                .foregroundStyle(DesignPickerCellPalette.chevron.color)
        }
        .padding(.horizontal, DesignPickerCellMetrics.horizontalPadding)
        .frame(maxWidth: .infinity)
        .frame(height: DesignPickerCellMetrics.height)
        .overlay {
            shape.strokeBorder(DesignPickerCellPalette.border.color, lineWidth: CGFloat.ds.border.thin)
        }
        .contentShape(shape)
    }
}

/// Figma Picker 칸 치수: 높이 36, 모서리 6, 좌우 14, 글자와 꺾쇠 사이 최소 16, 꺾쇠 14, Caption1 Regular.
enum DesignPickerCellMetrics {
    static let height: CGFloat = 36
    static let cornerRadius: CGFloat = CGFloat.ds.radius._6
    static let horizontalPadding: CGFloat = 14
    static let contentSpacing: CGFloat = CGFloat.ds.spacing.lg
    static let chevronSize: CGFloat = CGFloat.ds.iconSize._14
    static let textStyle = TextStyle.ds.caption1.regular
}

/// Figma Picker 칸 색: 테두리 `border/neutral/40`, 값 `text/neutral/primary`, placeholder `text/neutral/tertiary`,
/// 꺾쇠 `text/neutral/subtle`. 채움은 없다.
enum DesignPickerCellPalette {
    static let border = SemanticColor.border.neutral._40
    static let chevron = SemanticColor.text.neutral.subtle

    static func text(isEmpty: Bool) -> ThemedColor {
        isEmpty ? SemanticColor.text.neutral.tertiary : SemanticColor.text.neutral.primary
    }
}
