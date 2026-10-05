import SwiftUI

/// 여러 줄 칸의 꼴.
public enum DesignTextAreaStyle: Equatable, Sendable {
    /// 여러 줄 칸(시안 long). 테두리와 바탕이 있고 입력 전·중·뒤로 바뀐다.
    case standard
    /// 캡션 칸. 테두리와 바탕이 없다.
    case caption
}

/// 여러 줄·캡션 입력 칸. 칸 안 오른쪽 아래에 「현재/최대」를 그린다.
/// 최대를 넘는 입력은 받지 않는다. 최대보다 긴 값이 넘어오면 그대로 두고 「55/50」으로 보이며 지우기만 받는다.
/// 포커스는 칸에 `.focused($focus, equals:)` 를 건다.
public struct DesignTextArea: View {
    private let label: String?
    @Binding private var text: String
    private let placeholder: String
    private let maxLength: Int
    private let isRequired: Bool
    private let style: DesignTextAreaStyle
    @State private var isEditing = false

    public init(
        _ label: String? = nil,
        text: Binding<String>,
        placeholder: String,
        maxLength: Int,
        isRequired: Bool = false,
        style: DesignTextAreaStyle = .standard
    ) {
        self.label = label
        _text = text
        self.placeholder = placeholder
        self.maxLength = maxLength
        self.isRequired = isRequired
        self.style = style
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
                limit: limit
            ) { editing in
                isEditing = editing
            }
            .overlay(alignment: .bottomTrailing) {
                counter(limit, layout: layout)
            }
            .designInputBox(palette, height: layout.height, alignment: .topLeading)
        }
    }

    private var currentPalette: DesignInputPalette {
        switch style {
        case .standard:
            DesignInputStyleResolver.field(DesignInputPhase(isEditing: isEditing, isEmpty: text.isEmpty))
        case .caption:
            DesignInputStyleResolver.caption
        }
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
            textColor: palette.text,
            placeholder: placeholder,
            placeholderStyle: layout.placeholderStyle,
            placeholderColor: palette.placeholder,
            tint: DesignInputStyleResolver.tint,
            accessibilityLabel: label ?? placeholder,
            textInsets: layout.textInsets
        )
    }
}
