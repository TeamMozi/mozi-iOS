import SwiftUI

/// 체크박스. 선택 여부는 쓰는 쪽이 넘기고, 누르면 뒤집는다.
/// `title` 은 VoiceOver 가 읽는 이름이다. 화면에 그리지 않는다(옆 글은 쓰는 화면이 놓는다).
public struct DesignCheckbox: View {
    private let title: String
    @Binding private var isOn: Bool
    private let style: DesignCheckboxStyle

    public init(_ title: String, isOn: Binding<Bool>, style: DesignCheckboxStyle) {
        self.title = title
        _isOn = isOn
        self.style = style
    }

    public var body: some View {
        let palette = DesignCheckboxStyleResolver.resolve(style: style, isOn: isOn)
        Button {
            isOn.toggle()
        } label: {
            ZStack {
                Circle()
                    .fill(palette.fill?.color ?? .clear)
                if let border = palette.border {
                    Circle()
                        .strokeBorder(border.color, lineWidth: CGFloat.ds.border.thin)
                }
                mark(palette)
            }
            .frame(width: palette.diameter, height: palette.diameter)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityValue(selectionDescription)
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }

    @ViewBuilder
    private func mark(_ palette: DesignCheckboxPalette) -> some View {
        if let content = palette.content {
            switch style {
            case .check, .vote:
                Image.ds.icon.check.outlined
                    .iconSize(DesignCheckboxMetrics.checkIconSize)
                    .foregroundStyle(content.color)
            case let .order(number):
                DesignText("\(number)", style: TextStyle.ds.headline.semiBold, color: content.color, lineLimit: 1)
            }
        }
    }

    private var selectionDescription: String {
        switch style {
        case .check, .vote:
            isOn ? "선택됨" : "선택 안 됨"
        case let .order(number):
            isOn ? "\(number)번째" : "선택 안 됨"
        }
    }
}
