import SharedDesignSystem
import SwiftUI
import UIKit

/// 「기본」 탭의 단색 3:4 견본. 저작권이 불분명한 이미지 대신 디자인 시스템 색을 쓴다.
/// 고른 견본은 이 색으로 칠한 그림을 포스터로 올린다. 기기 모드와 상관없이 라이트 값으로 칠한다.
@MainActor
enum PosterSwatch {
    static var count: Int {
        palette.count
    }

    nonisolated static func id(_ index: Int) -> String {
        "swatch-\(index)"
    }

    static func color(at index: Int) -> Color {
        Color(uiColor: uiColor(at: index))
    }

    static func uiColor(at index: Int) -> UIColor {
        UIColor(palette[index % palette.count])
            .resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
    }

    private static let palette: [Color] = [
        Color.ds.fill.accent.default,
        Color.ds.fill.accent.muted,
        Color.ds.fill.accent.vivid,
        Color.ds.fill.neutral.strong,
        Color.ds.fill.neutral.heavy,
        Color.ds.fill.neutral.inverse,
    ]
}
