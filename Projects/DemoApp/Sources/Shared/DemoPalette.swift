import SwiftUI

/// 목업에 있지만 디자인 시스템에 의미 토큰이 없는 색. 데모 앱 화면에만 쓴다.
enum DemoPalette {
    /// #464321. 상태 시트에서 고른 줄 바탕.
    static let selectedRow = Color(red: 0x46 / 255.0, green: 0x43 / 255.0, blue: 0x21 / 255.0)
    /// #5D592C. 「이번 빌드에서 바뀐 것」 칸 테두리.
    static let changeBorder = Color(red: 0x5D / 255.0, green: 0x59 / 255.0, blue: 0x2C / 255.0)
    /// #999999. 칸 제목, 줄 보조 글, 글꼴 이름.
    static let caption = Color(white: 0x99 / 255.0)
    /// #666666. 줄 끝 화살표.
    static let chevron = Color(white: 0x66 / 255.0)
}
