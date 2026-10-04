import SwiftUI

/// 디자인 시스템 화면 위 모드 전환. 시스템은 기기 모드를 덮어쓰지 않는다.
public enum GalleryAppearance: String, CaseIterable, Identifiable {
    case system
    case dark
    case light

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .system: "시스템"
        case .dark: "다크"
        case .light: "라이트"
        }
    }

    public var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .dark: .dark
        case .light: .light
        }
    }
}
