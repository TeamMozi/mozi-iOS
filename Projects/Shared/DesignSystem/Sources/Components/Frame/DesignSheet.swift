import SwiftUI
import UIKit

/// 바텀시트 딤과 몸통 색, 높이 규칙.
enum DesignSheetMetrics {
    static let dim = SemanticColor.overlay.gray.default
    static let background = SemanticColor.fill.neutral.default

    /// 높이를 넘기지 않으면 시스템 기본인 large 하나다.
    static func detents(from detents: [PresentationDetent]) -> [PresentationDetent] {
        detents.isEmpty ? [.large] : detents
    }

    /// 시스템 딤을 끄는 상한. 실제로 가장 큰 높이여야 한다. 더 작으면 그 위 높이에서 시스템 딤이 남고,
    /// 더 크면(medium 시트에 large) 시스템 딤이 다시 생긴다.
    /// 높이끼리 비교할 방법이 없어 `.large` 가 있으면 `.large`, 없으면 배열의 마지막을 가장 큰 높이로 받는다.
    static func largestDetent(in detents: [PresentationDetent]) -> PresentationDetent {
        let detents = self.detents(from: detents)
        return detents.contains(.large) ? .large : detents[detents.count - 1]
    }

    /// 딤 짙기. 시트 위 끝이 자리 잡은 높이(`restingTop`)에 있으면 1, 화면 아래 끝(`containerHeight`)까지 내려가면 0 이다.
    /// 그 사이는 내려간 만큼 옅어진다. 자리 잡은 높이보다 위면 1 이다.
    static func dimOpacity(sheetTop: CGFloat, restingTop: CGFloat, containerHeight: CGFloat) -> Double {
        let travel = containerHeight - restingTop
        guard travel > 0 else { return sheetTop < containerHeight ? 1 : 0 }
        return Double(min(max((containerHeight - sheetTop) / travel, 0), 1))
    }

    /// 단계별 딤 짙기. 여는 중이면 올라갈 자리(`targetTop`), 닫는 중이면 닫기 직전에 자리 잡은 높이(`restingTop`)를
    /// 기준으로 한다. 떠 있는 동안은 어느 높이에 있든, 높이 사이를 오가든 1 이다.
    static func dimOpacity(
        phase: DesignSheetPhase,
        shownTop: CGFloat,
        targetTop: CGFloat,
        restingTop: CGFloat?,
        containerHeight: CGFloat
    ) -> Double {
        switch phase {
        case .presenting:
            dimOpacity(sheetTop: shownTop, restingTop: targetTop, containerHeight: containerHeight)
        case .shown:
            1
        case .dismissing:
            dimOpacity(sheetTop: shownTop, restingTop: restingTop ?? targetTop, containerHeight: containerHeight)
        }
    }

    /// 닫기 기준 높이. 시트가 선 자리 가운데 가장 낮은 곳(가장 작은 높이)을 지킨다. 닫는 중에는 바꾸지 않는다.
    /// 마지막 위치를 그대로 쓰면, 멈춰 있어 드물게 읽는 동안 위로 끌다 바로 내려 닫을 때 오른 자리가 기준이 된다.
    static func restingTop(phase: DesignSheetPhase, targetTop: CGFloat, previous: CGFloat?) -> CGFloat? {
        guard phase != .dismissing else { return previous }
        return max(previous ?? targetTop, targetTop)
    }

    /// 떠 있고 멈춰 있으면 딤이 1 로 고정이라 매 프레임 읽지 않아도 된다.
    static func needsEveryFrame(phase: DesignSheetPhase, shownTop: CGFloat, targetTop: CGFloat) -> Bool {
        phase != .shown || shownTop != targetTop
    }
}

/// 시트 표시 단계. 시스템은 가장 작은 높이 아래로 끌기 시작하면 닫기 전환을 시작한다.
enum DesignSheetPhase: Equatable {
    case presenting
    case shown
    case dismissing

    init(isBeingPresented: Bool, isBeingDismissed: Bool) {
        if isBeingDismissed {
            self = .dismissing
        } else if isBeingPresented {
            self = .presenting
        } else {
            self = .shown
        }
    }
}

public extension View {
    /// 시스템 시트를 띄우고 뒤 화면 전체를 Figma 딤 `overlay/gray/default` 로 덮는다. 시스템 딤은 끈다.
    /// 딤 짙기는 시트 위치를 따른다. 시트가 어느 높이에든 자리 잡으면 다 짙고, 올라오고 내려가는 동안,
    /// 손으로 가장 작은 높이 아래로 끌어내리는 동안 그만큼 옅어진다.
    /// 딤을 누르면 닫힌다(large 는 시스템이 위쪽 띠 탭을 받지 않아 닫히지 않는다).
    /// 시트 몸통은 `fill/neutral/default` 로 칠한다. 상태바는 어디에 걸어도 덮인다.
    /// `NavigationStack` 안쪽 화면에 걸면 헤더는 딤 위에 남고, 시트가 떠 있어도 헤더 버튼이 눌린다.
    /// `NavigationStack` 바깥에 걸면 헤더도 덮이고, 헤더 자리를 누르면 시트가 닫힌다.
    /// - Parameter detents: 시트 높이. 작은 것부터 적는다. `.large` 가 없으면 마지막을 가장 큰 높이로 본다.
    func designSheet<Content: View>(
        isPresented: Binding<Bool>,
        detents: [PresentationDetent] = [.large],
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        DesignSheetHost(
            base: self,
            isPresented: isPresented.wrappedValue,
            dismiss: { isPresented.wrappedValue = false },
            present: { base, position in
                base.sheet(isPresented: isPresented, onDismiss: onDismiss) {
                    content().modifier(DesignSheetStyle(detents: detents, position: position))
                }
            }
        )
    }

    /// `item` 이 있는 동안 시트를 띄운다. 딤·몸통·높이 규칙은 `designSheet(isPresented:)` 와 같다.
    /// - Parameter detents: 띄운 항목마다 시트 높이. 작은 것부터 적는다.
    func designSheet<Item: Identifiable, Content: View>(
        item: Binding<Item?>,
        detents: @escaping (Item) -> [PresentationDetent] = { _ in [.large] },
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View {
        DesignSheetHost(
            base: self,
            isPresented: item.wrappedValue != nil,
            dismiss: { item.wrappedValue = nil },
            present: { base, position in
                base.sheet(item: item, onDismiss: onDismiss) { presented in
                    content(presented).modifier(DesignSheetStyle(detents: detents(presented), position: position))
                }
            }
        )
    }
}

/// 시트 안에서 읽은 딤 짙기를 띄우는 화면의 딤에 넘기는 통로. 시트는 별도 표시 계층이라 값을 객체로 건넨다.
@MainActor @Observable
private final class DesignSheetPosition {
    var dimOpacity: Double = 0
}

/// 띄우는 화면. 시트를 걸고 그 위에 딤을 깐다.
private struct DesignSheetHost<Base: View, Presented: View>: View {
    let base: Base
    let isPresented: Bool
    let dismiss: () -> Void
    let present: (Base, DesignSheetPosition) -> Presented
    @State private var position = DesignSheetPosition()

    var body: some View {
        // 시스템 딤을 꺼 뒤 화면이 VoiceOver 에 열려 있으므로, 떠 있는 동안 뒤 화면을 접근성에서 숨긴다.
        present(base, position).accessibilityHidden(isPresented).overlay {
            DesignSheetDim(position: position, isPresented: isPresented, dismiss: dismiss)
        }
    }
}

/// 띄우는 화면 위 딤. 늘 두고 투명도만 바꾼다. 짙기를 이 뷰만 읽어, 매 프레임 바뀌어도 이 뷰만 다시 그린다.
private struct DesignSheetDim: View {
    let position: DesignSheetPosition
    let isPresented: Bool
    let dismiss: () -> Void

    var body: some View {
        DesignSheetMetrics.dim.color
            .ignoresSafeArea()
            .opacity(position.dimOpacity)
            .allowsHitTesting(isPresented)
            .onTapGesture(perform: dismiss)
            .accessibilityHidden(true)
    }
}

/// 시트 안쪽. 시스템 딤을 끄고 몸통을 불투명하게 칠한다. 기본 유리 몸통은 딤이 비쳐 색이 바뀐다.
private struct DesignSheetStyle: ViewModifier {
    let detents: [PresentationDetent]
    let position: DesignSheetPosition

    func body(content: Content) -> some View {
        content
            .presentationDetents(Set(DesignSheetMetrics.detents(from: detents)))
            .presentationBackgroundInteraction(.enabled(upThrough: DesignSheetMetrics.largestDetent(in: detents)))
            .presentationBackground(DesignSheetMetrics.background.color)
            .background(DesignSheetPositionReader(position: position))
    }
}

/// 시트 위 끝을 매 프레임 읽는다. SwiftUI 의 위치 변화 알림은 시트가 열리고 닫히는 애니메이션 중에 오지 않아,
/// 시트 컨테이너의 화면에 보이는 위치(presentation layer)를 화면 주사율로 읽는다.
private struct DesignSheetPositionReader: UIViewRepresentable {
    let position: DesignSheetPosition

    func makeUIView(context: Context) -> DesignSheetPositionView {
        DesignSheetPositionView(position: position)
    }

    func updateUIView(_ uiView: DesignSheetPositionView, context: Context) {
        uiView.position = position
    }
}

private final class DesignSheetPositionView: UIView {
    var position: DesignSheetPosition
    private var displayLink: CADisplayLink?
    /// 응답자 사슬을 매 프레임 오르지 않도록 창에 들어올 때 한 번 찾아 둔다.
    private weak var controller: UIPresentationController?
    /// 시트가 선 가장 낮은 위 끝(가장 작은 높이). 닫히는 동안 딤은 여기서 화면 아래 끝까지를 기준으로 옅어진다.
    private var restingTop: CGFloat?
    private var restingContainerHeight: CGFloat?
    private var readsEveryFrame = true

    init(position: DesignSheetPosition) {
        self.position = position
        super.init(frame: .zero)
        isUserInteractionEnabled = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        displayLink?.invalidate()
        displayLink = nil
        guard window != nil else {
            // 창에서 빠졌다. 시트가 다 내려가 사라졌거나, 시트 위에 전체 화면이 덮여 잠시 빠졌다.
            // 잠시 빠진 경우 딤은 덮은 화면 뒤에 있고, 창에 다시 들어오면 다음 프레임부터 다시 읽는다.
            position.dimOpacity = 0
            return
        }
        controller = findPresentationController()
        readsEveryFrame = true
        // 링크가 이 뷰를 붙잡지 않도록 약한 참조 중개를 대상으로 건다.
        let link = CADisplayLink(
            target: DesignSheetDisplayLinkProxy(view: self),
            selector: #selector(DesignSheetDisplayLinkProxy.tick)
        )
        link.add(to: .main, forMode: .common)
        // 지금 바로 읽지 않는다. 올라오는 애니메이션이 붙기 전이라 자리 잡은 위치가 읽혀 한 프레임 다 짙어진다.
        displayLink = link
    }

    func update() {
        guard let controller = controller ?? findPresentationController(),
              let sheetView = controller.presentedView,
              let containerView = controller.containerView else {
            setOpacity(1)
            return
        }
        self.controller = controller
        let shown = sheetView.layer.presentation() ?? sheetView.layer
        let container = containerView.layer.presentation() ?? containerView.layer
        let shownTop = shown.convert(shown.bounds, to: container).minY
        let targetTop = sheetView.convert(sheetView.bounds, to: containerView).minY
        let containerHeight = containerView.bounds.height
        if restingContainerHeight != containerHeight {
            // 화면이 돌면 높이 자리가 모두 바뀐다.
            restingTop = nil
            restingContainerHeight = containerHeight
        }
        let presented = controller.presentedViewController
        let phase = DesignSheetPhase(
            isBeingPresented: presented.isBeingPresented,
            isBeingDismissed: presented.isBeingDismissed
        )
        setOpacity(DesignSheetMetrics.dimOpacity(
            phase: phase,
            shownTop: shownTop,
            targetTop: targetTop,
            restingTop: restingTop,
            containerHeight: containerHeight
        ))
        restingTop = DesignSheetMetrics.restingTop(phase: phase, targetTop: targetTop, previous: restingTop)
        setReadsEveryFrame(DesignSheetMetrics.needsEveryFrame(phase: phase, shownTop: shownTop, targetTop: targetTop))
    }

    private func setOpacity(_ opacity: Double) {
        if position.dimOpacity != opacity {
            position.dimOpacity = opacity
        }
    }

    /// 멈춰 있는 동안은 초당 약 10번만 읽는다. 끌기를 시작하면 다음 읽기(최대 약 0.1초 뒤)부터 매 프레임으로 돌아간다.
    private func setReadsEveryFrame(_ everyFrame: Bool) {
        guard readsEveryFrame != everyFrame else { return }
        readsEveryFrame = everyFrame
        displayLink?.preferredFrameRateRange = everyFrame
            ? .default
            : CAFrameRateRange(minimum: 8, maximum: 15, preferred: 10)
    }

    private func findPresentationController() -> UIPresentationController? {
        var responder: UIResponder? = self
        while let next = responder?.next {
            if let controller = next as? UIViewController {
                return controller.presentationController
            }
            responder = next
        }
        return nil
    }
}

/// `CADisplayLink` 는 대상을 강하게 붙잡는다. 뷰가 사라지면 링크를 스스로 멈춘다.
@MainActor
private final class DesignSheetDisplayLinkProxy: NSObject {
    private weak var view: DesignSheetPositionView?

    init(view: DesignSheetPositionView) {
        self.view = view
    }

    @objc func tick(_ link: CADisplayLink) {
        guard let view else {
            link.invalidate()
            return
        }
        view.update()
    }
}
