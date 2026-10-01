import SwiftUI

extension View {
    /// 떠 있는 데모 버튼과 그 시트를 얹는다. 상태가 없는 화면은 `options` 를 비우고 `shortLabel` 을 nil 로 둔다.
    func demoMenu(
        shortLabel: String?,
        options: [DemoMenuOption],
        selectedID: String?,
        onSelect: @escaping (String) -> Void,
        onExit: @escaping () -> Void
    ) -> some View {
        modifier(
            DemoMenuModifier(
                shortLabel: shortLabel,
                options: options,
                selectedID: selectedID,
                onSelect: onSelect,
                onExit: onExit
            )
        )
    }
}

private struct DemoMenuModifier: ViewModifier {
    let shortLabel: String?
    let options: [DemoMenuOption]
    let selectedID: String?
    let onSelect: (String) -> Void
    let onExit: () -> Void

    @State private var isSheetPresented = false
    @State private var pendingAction: PendingAction?

    func body(content: Content) -> some View {
        content
            .overlay {
                DemoFloatingButton(shortLabel: shortLabel) {
                    isSheetPresented = true
                }
            }
            .sheet(isPresented: $isSheetPresented, onDismiss: runPendingAction) {
                DemoMenuSheet(
                    options: options,
                    selectedID: selectedID,
                    onExit: {
                        close(then: .exit)
                    },
                    onSelect: { id in
                        close(then: .select(id))
                    }
                )
            }
    }

    // 시트가 다 닫힌 뒤에 화면을 바꾼다. 닫히는 중에 화면을 갈면 시트가 남거나 이동이 씹힌다.
    private func close(then action: PendingAction) {
        pendingAction = action
        isSheetPresented = false
    }

    private func runPendingAction() {
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

private enum PendingAction: Equatable {
    case exit
    case select(String)
}
