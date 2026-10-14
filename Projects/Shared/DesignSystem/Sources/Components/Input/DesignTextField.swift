import SwiftUI

/// 한 줄 칸의 꼴.
public struct DesignTextFieldStyle: Equatable, Sendable {
    enum Kind: Equatable, Sendable {
        case standard
        case row
    }

    let kind: Kind
    let rowText: DesignRowText

    /// 상자 칸(시안 Input). 테두리와 바탕이 있고 입력 전·중·뒤로 바뀐다.
    public static let standard = DesignTextFieldStyle(kind: .standard, rowText: .standard)
    /// 줄 칸(시안 Row text). 테두리·바탕 없이 높이 54, 위아래 10·좌우 16. 둘레는 쓰는 쪽 칸이 그린다.
    public static let row = DesignTextFieldStyle(kind: .row, rowText: .standard)

    /// 글자 모양·색을 고른 줄 칸. 치수는 `.row` 와 같다.
    public static func row(text: DesignRowText) -> DesignTextFieldStyle {
        DesignTextFieldStyle(kind: .row, rowText: text)
    }
}

/// 한 줄 입력 칸. 값은 쓰는 쪽이 들고, 최대 글자 수를 넘는 입력은 받지 않는다(숫자는 그리지 않는다).
/// 최대보다 긴 값이 넘어오면 받자마자 잘라 쓰는 쪽 값도 바꾼다.
/// 포커스는 칸에 `.focused($focus, equals:)` 를 건다. 키보드를 가진 동안 입력 중 테두리가 켜진다.
public struct DesignTextField: View {
    private let label: String?
    @Binding private var text: String
    private let placeholder: String
    private let maxLength: Int
    private let isRequired: Bool
    private let style: DesignTextFieldStyle
    @State private var isEditing = false

    public init(
        _ label: String? = nil,
        text: Binding<String>,
        placeholder: String,
        maxLength: Int,
        isRequired: Bool = false,
        style: DesignTextFieldStyle = .standard
    ) {
        self.label = label
        _text = text
        self.placeholder = placeholder
        self.maxLength = maxLength
        self.isRequired = isRequired
        self.style = style
    }

    public var body: some View {
        let layout = DesignTextFieldLayout.of(style)
        let palette = currentPalette
        VStack(alignment: .leading, spacing: DesignInputMetrics.labelSpacing) {
            if let label {
                DesignInputLabel(title: label, isRequired: isRequired)
            }
            DesignTextFieldBridge(
                text: $text,
                appearance: appearance(palette, layout: layout),
                limit: DesignTextLimit(maxLength: maxLength, overflow: .truncate)
            ) { editing in
                isEditing = editing
            }
            .padding(.horizontal, layout.horizontalPadding)
            .designInputBox(palette, height: layout.height, alignment: .leading)
        }
    }

    private var currentPalette: DesignInputPalette {
        let phase = DesignInputPhase(isEditing: isEditing, isEmpty: text.isEmpty)
        switch style.kind {
        case .standard:
            return DesignInputStyleResolver.field(phase)
        case .row:
            return DesignInputStyleResolver.row(phase)
        }
    }

    private func appearance(_ palette: DesignInputPalette, layout: DesignTextFieldLayout) -> DesignTextInputAppearance {
        DesignTextInputAppearance(
            textStyle: layout.textStyle,
            textColor: style.rowText.textColor(fallback: palette.text),
            placeholder: placeholder,
            placeholderStyle: layout.placeholderStyle,
            placeholderColor: style.rowText.placeholderColor(fallback: palette.placeholder),
            tint: DesignInputStyleResolver.tint,
            accessibilityLabel: label ?? placeholder,
            textInsets: .zero
        )
    }
}
