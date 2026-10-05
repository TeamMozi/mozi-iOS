import SwiftUI

/// 한 줄 입력 칸. 값은 쓰는 쪽이 들고, 최대 글자 수를 넘는 입력은 받지 않는다(숫자는 그리지 않는다).
/// 최대보다 긴 값이 넘어오면 받자마자 잘라 쓰는 쪽 값도 바꾼다.
/// 포커스는 칸에 `.focused($focus, equals:)` 를 건다. 키보드를 가진 동안 입력 중 테두리가 켜진다.
public struct DesignTextField: View {
    private let label: String?
    @Binding private var text: String
    private let placeholder: String
    private let maxLength: Int
    private let isRequired: Bool
    @State private var isEditing = false

    public init(
        _ label: String? = nil,
        text: Binding<String>,
        placeholder: String,
        maxLength: Int,
        isRequired: Bool = false
    ) {
        self.label = label
        _text = text
        self.placeholder = placeholder
        self.maxLength = maxLength
        self.isRequired = isRequired
    }

    public var body: some View {
        let palette = DesignInputStyleResolver.field(DesignInputPhase(isEditing: isEditing, isEmpty: text.isEmpty))
        VStack(alignment: .leading, spacing: DesignInputMetrics.labelSpacing) {
            if let label {
                DesignInputLabel(title: label, isRequired: isRequired)
            }
            DesignTextFieldBridge(
                text: $text,
                appearance: appearance(palette),
                limit: DesignTextLimit(maxLength: maxLength, overflow: .truncate)
            ) { editing in
                isEditing = editing
            }
            .padding(.horizontal, DesignInputMetrics.horizontalPadding)
            .designInputBox(palette, height: DesignInputMetrics.fieldHeight, alignment: .leading)
        }
    }

    private func appearance(_ palette: DesignInputPalette) -> DesignTextInputAppearance {
        DesignTextInputAppearance(
            textStyle: TextStyle.ds.body.regular,
            textColor: palette.text,
            placeholder: placeholder,
            placeholderStyle: TextStyle.ds.body.regular,
            placeholderColor: palette.placeholder,
            tint: DesignInputStyleResolver.tint,
            accessibilityLabel: label ?? placeholder,
            textInsets: .zero
        )
    }
}
