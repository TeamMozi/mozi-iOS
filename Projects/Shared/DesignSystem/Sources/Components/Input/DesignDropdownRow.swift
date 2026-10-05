import SwiftUI

/// 드롭다운 줄의 칸 하나. 값이 없으면 placeholder 를 그린다.
/// 칸을 누르면 `options` 메뉴가 뜨고, 고르면 `onSelect` 가 불린다. 지금 값은 쓰는 쪽이 넘긴다.
public struct DesignDropdownCell {
    let value: String?
    let placeholder: String
    let options: [String]
    let onSelect: @MainActor (String) -> Void

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

    /// 메뉴가 떠 있어도 입력 중 테두리를 켜지 않는다. 입력 전·뒤 두 상태만 쓴다.
    var palette: DesignInputPalette {
        DesignInputStyleResolver.field(DesignInputPhase(isEditing: false, isEmpty: value == nil))
    }
}

/// 라벨·필수 표시 아래에 드롭다운 칸 1~3개를 간격 6으로 나란히 둔다(예: 생년월일 년·월·일).
public struct DesignDropdownRow: View {
    private let label: String
    private let isRequired: Bool
    private let cells: [DesignDropdownCell]

    public init(_ label: String, isRequired: Bool = false, cells: [DesignDropdownCell]) {
        self.label = label
        self.isRequired = isRequired
        self.cells = cells
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DesignInputMetrics.labelSpacing) {
            DesignInputLabel(title: label, isRequired: isRequired)
            HStack(spacing: DesignInputMetrics.cellSpacing) {
                ForEach(Array(cells.enumerated()), id: \.offset) { _, cell in
                    DropdownCellView(rowLabel: label, cell: cell)
                }
            }
        }
    }
}

private struct DropdownCellView: View {
    let rowLabel: String
    let cell: DesignDropdownCell

    var body: some View {
        Menu {
            DesignMenuOptions(options: cell.options, selected: cell.value, title: { $0 }, onSelect: cell.onSelect)
        } label: {
            box
        }
        .menuIndicator(.hidden)
        .accessibilityLabel("\(rowLabel) \(cell.placeholder)")
        .accessibilityValue(cell.value ?? "")
        .accessibilityAddTraits(.isButton)
    }

    private var box: some View {
        let palette = cell.palette
        return HStack(spacing: DesignInputMetrics.cellContentSpacing) {
            DesignText(
                cell.value ?? cell.placeholder,
                style: TextStyle.ds.body.regular,
                color: (cell.value == nil ? palette.placeholder : palette.text).color,
                lineLimit: 1
            )
            Spacer(minLength: 0)
            Image.ds.icon.chevron.down
                .iconSize(DesignInputMetrics.chevronSize)
                .foregroundStyle(DesignInputStyleResolver.chevron.color)
        }
        .padding(.horizontal, DesignInputMetrics.horizontalPadding)
        .designInputBox(palette, height: DesignInputMetrics.fieldHeight, alignment: .leading)
    }
}
