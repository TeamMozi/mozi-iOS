import MoziDemoKit
import SwiftUI
import UIKit

/// 데모 버튼과 데모 메뉴가 보는 값. 화면 데모 쪽 수식어가 채우고, 위 창의 화면이 읽는다.
@MainActor
@Observable
final class DemoMenuOverlayModel {
    var shortLabel: String?
    var options: [DemoMenuOption] = []
    var selectedID: String?
    var selectsAppearance = true
    var appearance = DemoMenuAppearance.initial
    var isSheetPresented = false

    @ObservationIgnored var onSelect: (String) -> Void = { _ in }
    @ObservationIgnored var onExit: () -> Void = {}
    @ObservationIgnored private var pendingAction: PendingAction?

    // 시트가 다 닫힌 뒤에 화면을 바꾼다. 닫히는 중에 화면을 갈면 시트가 남거나 이동이 씹힌다.
    func close(then action: PendingAction) {
        pendingAction = action
        isSheetPresented = false
    }

    func runPendingAction() {
        guard let action = pendingAction else { return }
        pendingAction = nil
        switch action {
        case .exit:
            onExit()
        case let .select(id):
            onSelect(id)
        }
    }
}

enum PendingAction: Equatable {
    case exit
    case select(String)
}

/// 데모 버튼 창 하나를 갖는다. 화면 데모가 사라져 이 값이 풀리면 창도 내린다.
///
/// 화면 데모가 띄운 전체 화면 덮개는 아래 화면의 사라짐(`onDisappear`)을 부를 수 있어, 창은 그 신호로 내리지 않는다.
@MainActor
final class DemoMenuWindowHolder {
    let model = DemoMenuOverlayModel()
    private var window: DemoMenuPassThroughWindow?
    private var interfaceStyle: UIUserInterfaceStyle = .unspecified
    /// 화면 모드를 거는 앱 창. 화면 데모가 닫히면(창을 내리거나 이 값이 풀리면) 시스템으로 되돌린다.
    private weak var appWindow: UIWindow?

    func show() {
        guard window == nil, let scene = Self.activeScene() else { return }
        let window = DemoMenuPassThroughWindow(windowScene: scene)
        let host = UIHostingController(
            rootView: DemoMenuOverlayView(model: model) { [weak window] frame in
                window?.buttonFrame = frame
            }
        )
        host.view.backgroundColor = .clear
        window.rootViewController = host
        window.overrideUserInterfaceStyle = interfaceStyle
        window.isHidden = false
        self.window = window
        // 화면 모드를 고를 수 없는 화면(로그인, 디자인 시스템)은 앱 창을 잡지 않아 앱 창 모드를 건드리지 않는다.
        if model.selectsAppearance {
            appWindow = DemoMenuPassThroughWindow.appWindow(among: scene.windows)
        }
    }

    func hide() {
        resetAppWindow()
        window?.isHidden = true
        window = nil
    }

    /// 고른 화면 모드를 앱 창에 건다. 앱 창에 걸어야 화면 데모가 이미 띄운 덮개·시트(모임 상세의 사이드바 등)까지 바로 바뀐다.
    func apply(_ appearance: GalleryAppearance) {
        appWindow?.overrideUserInterfaceStyle = DemoMenuAppearance.interfaceStyle(for: appearance)
    }

    /// 버튼과 메뉴를 화면 데모가 실제로 보이는 모드(로그인의 다크 포함)에 맞춘다.
    func match(_ colorScheme: ColorScheme) {
        interfaceStyle = UIUserInterfaceStyle(colorScheme)
        window?.overrideUserInterfaceStyle = interfaceStyle
    }

    isolated deinit {
        resetAppWindow()
        window?.isHidden = true
    }

    private func resetAppWindow() {
        appWindow?.overrideUserInterfaceStyle = .unspecified
        appWindow = nil
    }

    private static func activeScene() -> UIWindowScene? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        return scenes.first { $0.activationState == .foregroundActive } ?? scenes.first
    }
}

/// 위 창의 화면. 데모 버튼을 그리고, 누르면 이 창에서 데모 메뉴 시트를 띄운다.
private struct DemoMenuOverlayView: View {
    @Bindable var model: DemoMenuOverlayModel
    let onButtonFrameChange: (CGRect) -> Void

    var body: some View {
        DemoFloatingButton(shortLabel: model.shortLabel, onFrameChange: onButtonFrameChange) {
            model.isSheetPresented = true
        }
        .sheet(isPresented: $model.isSheetPresented, onDismiss: model.runPendingAction) {
            DemoMenuSheet(
                options: model.options,
                selectedID: model.selectedID,
                appearance: model.selectsAppearance ? $model.appearance : nil,
                onExit: {
                    model.close(then: .exit)
                },
                onSelect: { id in
                    model.close(then: .select(id))
                }
            )
            .preferredColorScheme(model.appearance.colorScheme)
        }
    }
}
