import SwiftUI

public struct DesignButton: View {
    private let title: String
    private let variant: DesignButtonVariant
    private let size: DesignButtonSize
    private let isEnabled: Bool
    private let isFullWidth: Bool
    private let leadingIcon: Image?
    private let trailingIcon: Image?
    private let action: () -> Void

    public init(
        _ title: String,
        variant: DesignButtonVariant = .primary,
        size: DesignButtonSize = .md,
        isEnabled: Bool = true,
        isFullWidth: Bool = false,
        leadingIcon: Image? = nil,
        trailingIcon: Image? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.variant = variant
        self.size = size
        self.isEnabled = isEnabled
        self.isFullWidth = isFullWidth
        self.leadingIcon = leadingIcon
        self.trailingIcon = trailingIcon
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            labelContent
        }
        .buttonStyle(
            DesignButtonChromeStyle(
                variant: variant,
                size: size,
                isFullWidth: isFullWidth
            )
        )
        .disabled(!isEnabled)
    }

    private var labelContent: some View {
        let textStyle = size.textStyle

        // 너비/높이 ownership 은 DesignButtonChromeStyle 에 둔다.
        // full-width 레이아웃에서 padding/frame 순서를 일관되게 유지하기 위함.
        return HStack(spacing: size.contentGap) {
            if let leadingIcon {
                leadingIcon
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: size.iconSize, height: size.iconSize)
            }

            Text(title)
                .font(textStyle.font)
                .kerning(textStyle.letterSpacing)
                .lineSpacing(textStyle.additionalLineSpacing)
                .lineLimit(1)

            if let trailingIcon {
                trailingIcon
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: size.iconSize, height: size.iconSize)
            }
        }
    }
}
