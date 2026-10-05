import SwiftUI

/// iOS 기본 메뉴의 항목들. 지금 고른 항목에만 체크를 붙인다. 드롭다운 줄과 상태 드롭다운이 함께 쓴다.
struct DesignMenuOptions<Option: Equatable>: View {
    let options: [Option]
    let selected: Option?
    let title: (Option) -> String
    let onSelect: @MainActor (Option) -> Void

    var body: some View {
        ForEach(Array(options.enumerated()), id: \.offset) { _, option in
            Button {
                onSelect(option)
            } label: {
                if option == selected {
                    Label(title(option), systemImage: "checkmark")
                } else {
                    Text(title(option))
                }
            }
        }
    }
}
