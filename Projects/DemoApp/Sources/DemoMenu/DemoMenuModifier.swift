import MoziDemoKit
import SwiftUI

extension View {
    /// 떠 있는 데모 버튼과 그 시트를 얹는다. 상태가 없는 화면은 `options` 를 비우고 `shortLabel` 을 nil 로 둔다.
    ///
    /// 버튼과 시트는 앱 창 위의 창에 그려, 화면 데모가 띄운 덮개·시트 위에 뜬다.
    /// 시트의 「화면 모드」 는 앱 창에 걸려 이 화면 데모 전체(이미 띄운 시트·덮개 포함)에 바로 걸리고, 화면 데모를 닫으면 시스템으로 되돌린다.
    /// 자기 모드 전환이 있는 디자인 시스템 화면과 스스로 다크를 고르는 로그인 화면은 `selectsAppearance` 를 false 로 둔다.
    func demoMenu(
        shortLabel: String?,
        options: [DemoMenuOption],
        selectedID: String?,
        selectsAppearance: Bool = true,
        onSelect: @escaping (String) -> Void,
        onExit: @escaping () -> Void
    ) -> some View {
        modifier(
            DemoMenuModifier(
                shortLabel: shortLabel,
                options: options,
                selectedID: selectedID,
                selectsAppearance: selectsAppearance,
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
    let selectsAppearance: Bool
    let onSelect: (String) -> Void
    let onExit: () -> Void

    // 버튼과 시트는 앱 창 위의 창에 그린다. 화면 데모가 띄운 덮개·시트(모임 상세의 사이드바 등)보다 위에 뜬다.
    @State private var holder = DemoMenuWindowHolder()
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .onAppear(perform: showMenu)
            // 화면 모드는 앱 창에 건다. 화면의 선호(`preferredColorScheme`)는 가장 가까운 덮개 하나에만 걸려,
            // 그 안에서 이미 떠 있는 덮개(모임 상세의 사이드바 등)는 바뀌지 않는다.
            .onChange(of: holder.model.appearance) { _, appearance in
                holder.apply(appearance)
            }
            .onChange(of: shortLabel) { _, label in
                holder.model.shortLabel = label
            }
            .onChange(of: selectedID) { _, id in
                holder.model.selectedID = id
            }
            // 앱 창 모드(또는 로그인처럼 화면이 스스로 고른 모드)가 이 화면의 모드로 내려오면 버튼과 메뉴도 거기에 맞춘다.
            .onChange(of: colorScheme, initial: true) { _, scheme in
                holder.match(scheme)
            }
    }

    // 아래 화면이 덮개에 가려 사라짐을 불러도 창은 그대로 둔다. 창은 화면 데모가 닫혀 holder 가 풀릴 때 내린다.
    private func showMenu() {
        let model = holder.model
        model.shortLabel = shortLabel
        model.options = options
        model.selectedID = selectedID
        model.selectsAppearance = selectsAppearance
        model.onSelect = onSelect
        model.onExit = { [weak holder] in
            holder?.hide()
            onExit()
        }
        holder.show()
    }
}
