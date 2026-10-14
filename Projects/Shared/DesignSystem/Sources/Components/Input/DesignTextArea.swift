import SwiftUI

/// 여러 줄 칸의 꼴.
public enum DesignTextAreaStyle: Equatable, Sendable {
    /// 여러 줄 칸(시안 long). 테두리와 바탕이 있고 입력 전·중·뒤로 바뀐다.
    case standard
    /// 캡션 칸. 테두리와 바탕이 없다.
    case caption
    /// 줄 칸(시안 Row text·long text). 테두리·바탕 없이 위아래 10·좌우 16, 높이는 받은 값으로 고정한다.
    /// `showsCounter` 가 true 면 오른쪽 16·아래 10에 「현재/최대」를 그린다. 둘레는 쓰는 쪽 칸이 그린다.
    /// `text` 로 글자 모양·색을 고른다. 비우면 지금 모양(Body/Regular, 상태별 색)이다.
    case row(height: CGFloat, showsCounter: Bool, text: DesignRowText = .standard)
}

/// 여러 줄·캡션 입력 칸. 칸 안 오른쪽 아래에 「현재/최대」를 그린다(줄 칸은 켤 때만).
/// 최대를 넘는 입력은 받지 않는다. 최대보다 긴 값이 넘어오면 그대로 두고 「55/50」으로 보이며 지우기만 받는다.
/// 포커스는 칸에 `.focused($focus, equals:)` 를 건다.
public struct DesignTextArea: View {
    private let label: String?
    @Binding private var text: String
    private let placeholder: String
    private let maxLength: Int
    private let isRequired: Bool
    private let style: DesignTextAreaStyle
    /// 커서 위치(UTF-16). 칸이 키보드를 가진 동안 쓰고, 놓으면 nil 을 쓴다. 비우면 알리지 않는다.
    private let cursor: Binding<Int?>?
    @State private var isEditing = false

    public init(
        _ label: String? = nil,
        text: Binding<String>,
        placeholder: String,
        maxLength: Int,
        isRequired: Bool = false,
        style: DesignTextAreaStyle = .standard,
        cursor: Binding<Int?>? = nil
    ) {
        self.label = label
        _text = text
        self.placeholder = placeholder
        self.maxLength = maxLength
        self.isRequired = isRequired
        self.style = style
        self.cursor = cursor
    }

    public var body: some View {
        let layout = DesignTextAreaLayout.of(style)
        let palette = currentPalette
        let limit = DesignTextLimit(maxLength: maxLength, overflow: .keep)
        VStack(alignment: .leading, spacing: DesignInputMetrics.labelSpacing) {
            if let label {
                DesignInputLabel(title: label, isRequired: isRequired)
            }
            DesignTextViewBridge(
                text: $text,
                appearance: appearance(palette, layout: layout),
                limit: limit,
                cursor: cursor
            ) { editing in
                isEditing = editing
            }
            .overlay(alignment: .bottomTrailing) {
                if layout.showsCounter {
                    counter(limit, layout: layout)
                }
            }
            .designInputBox(palette, height: layout.height, alignment: .topLeading)
        }
    }

    private var currentPalette: DesignInputPalette {
        let phase = DesignInputPhase(isEditing: isEditing, isEmpty: text.isEmpty)
        switch style {
        case .standard:
            return DesignInputStyleResolver.field(phase)
        case .caption:
            return DesignInputStyleResolver.caption
        case .row:
            return DesignInputStyleResolver.row(phase)
        }
    }

    private var rowText: DesignRowText {
        if case let .row(_, _, text) = style {
            return text
        }
        return .standard
    }

    private func counter(_ limit: DesignTextLimit, layout: DesignTextAreaLayout) -> some View {
        DesignText(
            limit.counterText(for: text),
            style: TextStyle.ds.caption2.medium,
            color: DesignInputStyleResolver.counter.color,
            lineLimit: 1
        )
        .padding(.trailing, layout.counterTrailing)
        .padding(.bottom, layout.counterBottom)
        .allowsHitTesting(false)
        .accessibilityLabel("\(text.count)자, 최대 \(maxLength)자")
    }

    private func appearance(_ palette: DesignInputPalette, layout: DesignTextAreaLayout) -> DesignTextInputAppearance {
        DesignTextInputAppearance(
            textStyle: layout.textStyle,
            textColor: rowText.textColor(fallback: palette.text),
            placeholder: placeholder,
            placeholderStyle: layout.placeholderStyle,
            placeholderColor: rowText.placeholderColor(fallback: palette.placeholder),
            tint: DesignInputStyleResolver.tint,
            accessibilityLabel: label ?? placeholder,
            textInsets: layout.textInsets
        )
    }
}
