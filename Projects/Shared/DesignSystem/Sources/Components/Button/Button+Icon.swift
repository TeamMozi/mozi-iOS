import SwiftUI

public extension Button where Label == SwiftUI.Label<Text, Image> {
    /// 글자와 아이콘 버튼. 아이콘은 늘일 수 있게(`resizable`) 넘긴다.
    /// 아이콘 크기·간격·자리는 버튼 스타일이 정한다.
    init(_ title: String, icon: Image, action: @escaping @MainActor () -> Void) {
        self.init(action: action) {
            SwiftUI.Label {
                Text(title)
            } icon: {
                icon.resizable()
            }
        }
    }
}
