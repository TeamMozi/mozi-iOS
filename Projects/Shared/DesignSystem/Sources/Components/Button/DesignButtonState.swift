import Foundation

/// 버튼 한 상태. 비활성이 눌림보다 앞선다.
enum DesignButtonState: Equatable, Sendable {
    case `default`
    case pressed
    case disabled

    init(isEnabled: Bool, isPressed: Bool) {
        if !isEnabled {
            self = .disabled
        } else if isPressed {
            self = .pressed
        } else {
            self = .default
        }
    }
}

/// 눌림 시안이 없는 계열(소셜·글자·액션·Shortcut)이 눌렸을 때 쓰는 불투명도.
enum DesignButtonPressedOpacity {
    static let pressed: Double = 0.88

    static func value(isPressed: Bool) -> Double {
        isPressed ? pressed : 1
    }
}

/// 버튼 한 상태의 모양. 색은 다크·라이트 쌍이고, 바탕이 없는 계열은 `background` 가 nil 이다.
struct DesignButtonPalette: Equatable, Sendable {
    let background: ThemedColor?
    let content: ThemedColor
    let opacity: Double
}
