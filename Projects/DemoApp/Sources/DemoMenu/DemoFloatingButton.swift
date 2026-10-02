import SharedDesignSystem
import SwiftUI

/// 화면 오른쪽 아래에 떠 있는 데모 버튼. 지금 상태를 짧게 적고, 누르면 시트를 열고, 끌어서 옮긴다.
struct DemoFloatingButton: View {
    let shortLabel: String?
    let action: () -> Void

    @State private var settledOffset: CGSize = .zero
    @GestureState private var dragTranslation: CGSize = .zero

    var body: some View {
        GeometryReader { proxy in
            let container = proxy.size
            label
                .offset(
                    DemoFloatingButtonLayout.clampedOffset(
                        Self.sum(settledOffset, dragTranslation),
                        in: container
                    )
                )
                .gesture(
                    DragGesture(minimumDistance: 8)
                        .updating($dragTranslation) { value, state, _ in
                            state = value.translation
                        }
                        .onEnded { value in
                            settledOffset = DemoFloatingButtonLayout.clampedOffset(
                                Self.sum(settledOffset, value.translation),
                                in: container
                            )
                        }
                )
                .onTapGesture(perform: action)
                .padding(.trailing, DemoFloatingButtonLayout.trailingInset)
                .padding(.bottom, DemoFloatingButtonLayout.bottomInset)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
    }

    private var label: some View {
        VStack(spacing: DemoFloatingButtonStyle.labelSpacing) {
            Image(systemName: "line.3.horizontal")
                .font(TextStyle.ds.headline.semiBold.font)
            if let shortLabel {
                DesignText(
                    shortLabel,
                    style: TextStyle.ds.caption2.medium,
                    color: Color.ds.text.accent.subtle,
                    alignment: .center,
                    lineLimit: 1
                )
            }
        }
        .foregroundStyle(Color.ds.text.accent.subtle)
        .frame(width: DemoFloatingButtonLayout.diameter, height: DemoFloatingButtonLayout.diameter)
        .background(
            Color.ds.fill.neutral.subtle.opacity(DemoFloatingButtonStyle.backgroundOpacity),
            in: Circle()
        )
        .overlay {
            Circle()
                .strokeBorder(Color.ds.border.accent.basic, lineWidth: CGFloat.ds.border.thin)
        }
        .contentShape(Circle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("데모 메뉴 열기")
        .accessibilityValue(shortLabel ?? "")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction(.default, action)
    }

    private static func sum(_ lhs: CGSize, _ rhs: CGSize) -> CGSize {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
}

private enum DemoFloatingButtonStyle {
    static let labelSpacing: CGFloat = 1
    static let backgroundOpacity = 0.85
}
