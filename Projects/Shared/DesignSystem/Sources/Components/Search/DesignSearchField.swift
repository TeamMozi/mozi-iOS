import SwiftUI

/// 검색 칸. 값은 쓰는 쪽이 들고, 뒤로·필터 버튼은 쓰는 화면이 놓는다.
/// 납작형은 글자가 있을 때 오른쪽에 지우기 버튼을 그린다. 검색 실행은 칸에 `.onSubmit` 을 건다.
public struct DesignSearchField: View {
    @Binding private var text: String
    private let placeholder: String
    private let style: DesignSearchFieldStyle

    public init(text: Binding<String>, placeholder: String, style: DesignSearchFieldStyle) {
        _text = text
        self.placeholder = placeholder
        self.style = style
    }

    public var body: some View {
        let palette = DesignSearchFieldStyleResolver.palette(style)
        let metrics = DesignSearchFieldStyleResolver.metrics(style)
        let textStyle = TextStyle.ds.body.regular
        HStack(spacing: metrics.spacing) {
            if style == .glass {
                Image.ds.icon.search.outlined
                    .iconSize(DesignSearchFieldMetrics.iconSize)
                    .foregroundStyle(palette.icon.color)
            }
            TextField(text: $text, prompt: Text(placeholder).foregroundStyle(palette.placeholder.color)) {
                Text(placeholder)
            }
            .font(textStyle.font)
            .kerning(textStyle.letterSpacing)
            .foregroundStyle(palette.text.color)
            .tint(DesignSearchFieldStyleResolver.cursor.color)
            .submitLabel(.search)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            if style == .flat, !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image.ds.icon.xCircle.outlined
                        .iconSize(DesignSearchFieldMetrics.iconSize)
                        .foregroundStyle(palette.icon.color)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("지우기")
            }
        }
        .padding(.horizontal, metrics.horizontalPadding)
        .frame(maxWidth: .infinity, minHeight: metrics.height, maxHeight: metrics.height)
        .searchFieldBackground(style: style, palette: palette, metrics: metrics)
    }
}

private extension View {
    @ViewBuilder
    func searchFieldBackground(
        style: DesignSearchFieldStyle,
        palette: DesignSearchFieldPalette,
        metrics: DesignSearchFieldMetrics
    ) -> some View {
        switch style {
        case .glass:
            glassEffect(.regular, in: .capsule)
        case .flat:
            background(
                RoundedRectangle(cornerRadius: metrics.cornerRadius ?? 0, style: .continuous)
                    .fill(palette.background?.color ?? .clear)
            )
        }
    }
}
