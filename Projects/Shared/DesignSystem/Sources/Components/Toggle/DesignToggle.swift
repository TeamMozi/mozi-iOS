import SwiftUI

/// iOS 기본 스위치에 켜짐 색만 입힌다. 꺼짐 트랙은 시스템 기본이다.
/// `title` 은 VoiceOver 가 읽는 이름이다. 화면에 그리지 않는다.
public struct DesignToggle: View {
    private let title: String
    @Binding private var isOn: Bool

    public init(_ title: String, isOn: Binding<Bool>) {
        self.title = title
        _isOn = isOn
    }

    public var body: some View {
        Toggle(title, isOn: $isOn)
            .labelsHidden()
            .tint(DesignTogglePalette.onTint.color)
    }
}

/// Figma 에 의미 색이 없어 켜짐 색은 원시 초록 #6CE582 다. 의미 색이 생기면 옮긴다.
enum DesignTogglePalette {
    static let onTint = ThemedColor.fixed(PrimitiveColor.system.green)
}
