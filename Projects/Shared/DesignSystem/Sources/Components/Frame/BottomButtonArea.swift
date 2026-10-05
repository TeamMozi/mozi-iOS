import SwiftUI

/// 하단 버튼 영역의 버튼 배치 셋. Figma `Bottom Button Area` 의 Single · Split 5:5 · Split 3:7.
public enum BottomButtonArrangement: Sendable {
    /// 버튼 하나가 가로를 채운다. 위 여백 12.
    case single
    /// 버튼 둘이 같은 너비다. 위 여백 12.
    case split5To5
    /// 오른쪽 버튼이 240 이고 왼쪽 버튼이 남은 너비를 채운다. 위 여백 16.
    case split3To7

    var topPadding: CGFloat {
        self == .split3To7 ? CGFloat.ds.spacing.lg : CGFloat.ds.spacing.md
    }

    /// 버튼마다 받을 너비. 버튼 사이 간격을 뺀 너비를 배치대로 나눈다.
    /// 하나·5:5 는 같은 너비로 나눈다. 3:7 은 마지막 버튼이 240 을 먼저 받고, 모자라면 앞 버튼이 0 까지 줄어든다.
    func widths(in width: CGFloat, count: Int) -> [CGFloat] {
        guard count > 0 else { return [] }
        let gaps = BottomButtonAreaMetrics.spacing * CGFloat(count - 1)
        let available = max(0, width - gaps)
        switch self {
        case .single, .split5To5:
            return Array(repeating: available / CGFloat(count), count: count)
        case .split3To7:
            guard count > 1 else { return [available] }
            let trailing = min(BottomButtonAreaMetrics.trailingFixedWidth, available)
            let leading = (available - trailing) / CGFloat(count - 1)
            return Array(repeating: leading, count: count - 1) + [trailing]
        }
    }
}

/// 하단 버튼 영역 수치와 색. Figma `Bottom Button Area` 값이다.
enum BottomButtonAreaMetrics {
    static let horizontalPadding: CGFloat = CGFloat.ds.layout.margin
    static let spacing: CGFloat = CGFloat.ds.spacing.md
    static let topBorderWidth: CGFloat = CGFloat.ds.border.thin
    static let trailingFixedWidth: CGFloat = 240
    static let background = SemanticColor.fill.neutral.default
    static let topBorder = SemanticColor.border.neutral._10
}

/// Figma `Bottom Button Area`. 윗줄과 버튼 묶음을 빈 칸으로 받는다. 버튼과 윗줄 내용은 쓰는 화면이 넣는다.
/// 바탕은 `fill/neutral/default` 로 아래 끝까지 칠하고, 아래 여백은 안전 영역이 맡는다(Figma 34).
/// 화면에 붙일 때는 `.bottomButtonArea { BottomButtonArea(...) { ... } }` 를 쓴다.
public struct BottomButtonArea<Caption: View, Buttons: View>: View {
    private let arrangement: BottomButtonArrangement
    private let showsTopBorder: Bool
    private let caption: Caption
    private let buttons: Buttons

    public init(
        _ arrangement: BottomButtonArrangement = .single,
        showsTopBorder: Bool = false,
        @ViewBuilder caption: () -> Caption,
        @ViewBuilder buttons: () -> Buttons
    ) {
        self.arrangement = arrangement
        self.showsTopBorder = showsTopBorder
        self.caption = caption()
        self.buttons = buttons()
    }

    public var body: some View {
        VStack(spacing: BottomButtonAreaMetrics.spacing) {
            caption
            BottomButtonRowLayout(arrangement: arrangement) {
                buttons
            }
        }
        .padding(.top, arrangement.topPadding)
        .padding(.horizontal, BottomButtonAreaMetrics.horizontalPadding)
        .frame(maxWidth: .infinity)
        .background {
            BottomButtonAreaMetrics.background.color
                .ignoresSafeArea(edges: .bottom)
        }
        .overlay(alignment: .top) {
            if showsTopBorder {
                BottomButtonAreaMetrics.topBorder.color
                    .frame(height: BottomButtonAreaMetrics.topBorderWidth)
            }
        }
    }
}

public extension BottomButtonArea where Caption == EmptyView {
    /// 윗줄 없는 영역.
    init(
        _ arrangement: BottomButtonArrangement = .single,
        showsTopBorder: Bool = false,
        @ViewBuilder buttons: () -> Buttons
    ) {
        self.init(arrangement, showsTopBorder: showsTopBorder, caption: { EmptyView() }, buttons: buttons)
    }
}

/// 버튼 묶음을 배치대로 한 줄에 놓는다. 버튼마다 너비를 정해 주고, 줄 높이는 가장 높은 버튼을 따른다.
struct BottomButtonRowLayout: Layout {
    let arrangement: BottomButtonArrangement

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? idealWidth(of: subviews)
        let widths = arrangement.widths(in: width, count: subviews.count)
        let height = zip(subviews, widths)
            .map { subview, width in subview.sizeThatFits(ProposedViewSize(width: width, height: nil)).height }
            .max() ?? 0
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let widths = arrangement.widths(in: bounds.width, count: subviews.count)
        var x = bounds.minX
        for (subview, width) in zip(subviews, widths) {
            subview.place(
                at: CGPoint(x: x, y: bounds.minY),
                anchor: .topLeading,
                proposal: ProposedViewSize(width: width, height: bounds.height)
            )
            x += width + BottomButtonAreaMetrics.spacing
        }
    }

    private func idealWidth(of subviews: Subviews) -> CGFloat {
        let widths = subviews.map { $0.sizeThatFits(.unspecified).width }
        return widths.reduce(0, +) + BottomButtonAreaMetrics.spacing * CGFloat(max(0, subviews.count - 1))
    }
}

public extension View {
    /// 화면 아래에 하단 버튼 영역을 붙인다. 탭바를 숨긴다.
    /// 키보드가 올라와도 영역은 따라 올라가지 않고 키보드 뒤에 남는다. 본문은 그대로 키보드를 피한다.
    func bottomButtonArea<Area: View>(@ViewBuilder _ area: () -> Area) -> some View {
        modifier(BottomButtonAreaAttachment(area: area()))
    }
}

/// 본문 아래 여백. 키보드가 영역보다 높이 가리면 키보드가 가린 높이를, 아니면 영역 높이를 따른다.
enum BottomButtonAreaInset {
    static func content(areaHeight: CGFloat, fullHeight: CGFloat, keyboardAvoidingHeight: CGFloat) -> CGFloat {
        max(areaHeight, fullHeight - keyboardAvoidingHeight)
    }
}

/// 본문과 영역을 함께 키보드를 무시하게 두어 영역이 화면 맨 아래에 남게 한다.
/// 키보드를 피하는 일은 본문 아래 여백이 대신한다. 무시하기 전과 뒤의 높이 차가 키보드가 가린 높이다.
private struct BottomButtonAreaAttachment<Area: View>: ViewModifier {
    let area: Area
    @State private var areaHeight: CGFloat = 0
    @State private var fullHeight: CGFloat = 0
    @State private var keyboardAvoidingHeight: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .safeAreaPadding(
                .bottom,
                BottomButtonAreaInset.content(
                    areaHeight: areaHeight,
                    fullHeight: fullHeight,
                    keyboardAvoidingHeight: keyboardAvoidingHeight
                )
            )
            .overlay(alignment: .bottom) {
                area
                    .onGeometryChange(for: CGFloat.self) { proxy in
                        proxy.size.height
                    } action: { height in
                        areaHeight = height
                    }
            }
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.size.height
            } action: { height in
                fullHeight = height
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.size.height
            } action: { height in
                keyboardAvoidingHeight = height
            }
            .toolbar(.hidden, for: .tabBar)
    }
}
