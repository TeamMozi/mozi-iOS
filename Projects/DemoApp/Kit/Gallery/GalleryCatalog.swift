import SharedDesignSystem
import SwiftUI

/// 색 화면 한 칸. 이름은 `Color.ds` 뒤 경로이고, 칸 아래에는 `shortName` 을 적는다.
public struct GallerySwatch: Identifiable, Sendable {
    let name: String
    public let color: Color

    init(_ name: String, _ color: Color) {
        self.name = name
        self.color = color
    }

    public var id: String { name }

    /// 칸 아래에 적는 이름. 묶음 경로를 뺀 마지막 낱말이고, 숫자 낱말 앞의 `_` 는 뗀다.
    /// `border.neutral._10` → `10`, `text.neutral.primary` → `primary`.
    public var shortName: String {
        let last = name.split(separator: ".").last.map(String.init) ?? name
        return last.hasPrefix("_") ? String(last.dropFirst()) : last
    }
}

/// Figma 의미 색 묶음 하나. 제목은 Figma 경로다.
public struct GalleryColorGroup: Identifiable, Sendable {
    public let title: String
    public let swatches: [GallerySwatch]

    public var id: String { title }
}

/// 글자 화면 견본 하나. 이름은 `TextStyle.ds` 뒤 경로다.
public struct GalleryTextSample: Identifiable, Sendable {
    let name: String
    public let style: TextStyle

    init(_ name: String, _ style: TextStyle) {
        self.name = name
        self.style = style
    }

    public var id: String { name }

    /// 견본 위에 적는 이름. 묶음 이름을 뺀 굵기 낱말이다. `title2.semiBold` → `semiBold`.
    public var shortName: String {
        name.split(separator: ".").last.map(String.init) ?? name
    }

    /// `16 · 줄 24 · 자간 -1% (-0.16pt) · SemiBold` 꼴. 굵기는 글꼴 이름의 `-` 뒤다.
    public var metricsLabel: String {
        let size = Self.format(style.size)
        let lineHeight = Self.format(style.lineHeight)
        let percent = Self.format(style.letterSpacingEm * 100)
        let points = Self.format(style.letterSpacing)
        let weight = style.fontName.split(separator: "-").last.map(String.init) ?? style.fontName
        return "\(size) · 줄 \(lineHeight) · 자간 \(percent)% (\(points)pt) · \(weight)"
    }

    // 소수 둘째 자리까지 반올림하고 끝의 0 은 뗀다. -0.01 * 100 같은 부동소수 오차도 여기서 지운다.
    private static func format(_ value: CGFloat) -> String {
        Double(value).formatted(
            .number
                .precision(.fractionLength(0...2))
                .grouping(.never)
                .locale(Locale(identifier: "en_US_POSIX"))
        )
    }
}

/// Figma 글자 스타일 묶음 하나. 제목은 Figma 표기다.
public struct GalleryTextGroup: Identifiable, Sendable {
    public let title: String
    public let samples: [GalleryTextSample]

    public var id: String { title }
}

/// 첫 화면 「디자인 시스템」 칸의 줄과 그 줄이 여는 화면. 칸에는 이 순서로 보인다.
public enum GalleryScreen: String, CaseIterable, Identifiable {
    case color
    case typography
    case button
    case screenStatus

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .color: "색"
        case .typography: "글자"
        case .button: "버튼"
        case .screenStatus: "화면 상태"
        }
    }
}

/// 화면 상태 화면에서 고르는 네 상태. 실패 문구는 견본이다.
public enum GalleryScreenStatusSample: String, CaseIterable, Identifiable {
    case idle
    case loading
    case actionFailed
    case loadFailed

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .idle: "대기"
        case .loading: "불러오는 중"
        case .actionFailed: "동작 실패"
        case .loadFailed: "불러오기 실패"
        }
    }

    public var status: ScreenStatus {
        switch self {
        case .idle: .idle
        case .loading: .loading
        case .actionFailed: .actionFailed(message: "저장하지 못했어요")
        case .loadFailed: .loadFailed(message: "내용을 불러오지 못했어요")
        }
    }
}

/// 색 화면의 의미 색 63개와 글자 화면의 글자 스타일 21개(묶음 8개). 둘 다 Figma 순서다.
public enum GalleryCatalog {
    /// 글자 화면 견본. 가장 작은 글자에서도 폭 안에서 두 줄 넘게 넘어가는 길이다.
    public static let sampleText = "동네라서 가능한 모든 모임. 가까운 이웃과 취미를 나누고, 주말마다 새로운 모임을 열어 함께 시간을 보내요."

    public static let colorGroups: [GalleryColorGroup] = [
        GalleryColorGroup(
            title: "text/neutral",
            swatches: [
                GallerySwatch("text.neutral.primary", Color.ds.text.neutral.primary),
                GallerySwatch("text.neutral.secondary", Color.ds.text.neutral.secondary),
                GallerySwatch("text.neutral.tertiary", Color.ds.text.neutral.tertiary),
                GallerySwatch("text.neutral.subtle", Color.ds.text.neutral.subtle),
                GallerySwatch("text.neutral.faint", Color.ds.text.neutral.faint),
                GallerySwatch("text.neutral.inverse", Color.ds.text.neutral.inverse),
            ]
        ),
        GalleryColorGroup(
            title: "text/accent",
            swatches: [
                GallerySwatch("text.accent.default", Color.ds.text.accent.default),
                GallerySwatch("text.accent.subtle", Color.ds.text.accent.subtle),
                GallerySwatch("text.accent.highlight", Color.ds.text.accent.highlight),
                GallerySwatch("text.accent.strong", Color.ds.text.accent.strong),
            ]
        ),
        GalleryColorGroup(
            title: "fill/neutral",
            swatches: [
                GallerySwatch("fill.neutral.default", Color.ds.fill.neutral.default),
                GallerySwatch("fill.neutral.surface", Color.ds.fill.neutral.surface),
                GallerySwatch("fill.neutral.subtle", Color.ds.fill.neutral.subtle),
                GallerySwatch("fill.neutral.raised", Color.ds.fill.neutral.raised),
                GallerySwatch("fill.neutral.strong", Color.ds.fill.neutral.strong),
                GallerySwatch("fill.neutral.muted", Color.ds.fill.neutral.muted),
                GallerySwatch("fill.neutral.heavy", Color.ds.fill.neutral.heavy),
                GallerySwatch("fill.neutral.inverse", Color.ds.fill.neutral.inverse),
            ]
        ),
        GalleryColorGroup(
            title: "fill/accent",
            swatches: [
                GallerySwatch("fill.accent.default", Color.ds.fill.accent.default),
                GallerySwatch("fill.accent.vivid", Color.ds.fill.accent.vivid),
                GallerySwatch("fill.accent.muted", Color.ds.fill.accent.muted),
            ]
        ),
        GalleryColorGroup(
            title: "border/neutral",
            swatches: [
                GallerySwatch("border.neutral._0", Color.ds.border.neutral._0),
                GallerySwatch("border.neutral._10", Color.ds.border.neutral._10),
                GallerySwatch("border.neutral._20", Color.ds.border.neutral._20),
                GallerySwatch("border.neutral._30", Color.ds.border.neutral._30),
                GallerySwatch("border.neutral._40", Color.ds.border.neutral._40),
                GallerySwatch("border.neutral._50", Color.ds.border.neutral._50),
                GallerySwatch("border.neutral.inverse", Color.ds.border.neutral.inverse),
            ]
        ),
        GalleryColorGroup(
            title: "border/accent",
            swatches: [
                GallerySwatch("border.accent.basic", Color.ds.border.accent.basic),
                GallerySwatch("border.accent.dark", Color.ds.border.accent.dark),
                GallerySwatch("border.accent.darker", Color.ds.border.accent.darker),
            ]
        ),
        GalleryColorGroup(
            title: "button/background/main",
            swatches: [
                GallerySwatch("button.background.main.default", Color.ds.button.background.main.default),
                GallerySwatch("button.background.main.pressed", Color.ds.button.background.main.pressed),
                GallerySwatch("button.background.main.disabled", Color.ds.button.background.main.disabled),
            ]
        ),
        GalleryColorGroup(
            title: "button/background/neutral",
            swatches: [
                GallerySwatch("button.background.neutral.default", Color.ds.button.background.neutral.default),
                GallerySwatch("button.background.neutral.pressed", Color.ds.button.background.neutral.pressed),
                GallerySwatch("button.background.neutral.disabled", Color.ds.button.background.neutral.disabled),
            ]
        ),
        GalleryColorGroup(
            title: "button/background/ghost",
            swatches: [
                GallerySwatch("button.background.ghost.default", Color.ds.button.background.ghost.default),
                GallerySwatch("button.background.ghost.pressed", Color.ds.button.background.ghost.pressed),
                GallerySwatch("button.background.ghost.disabled", Color.ds.button.background.ghost.disabled),
            ]
        ),
        GalleryColorGroup(
            title: "button/background/icon",
            swatches: [
                GallerySwatch("button.background.icon.default", Color.ds.button.background.icon.default),
            ]
        ),
        GalleryColorGroup(
            title: "button/label/main",
            swatches: [
                GallerySwatch("button.label.main.default", Color.ds.button.label.main.default),
                GallerySwatch("button.label.main.pressed", Color.ds.button.label.main.pressed),
                GallerySwatch("button.label.main.disabled", Color.ds.button.label.main.disabled),
            ]
        ),
        GalleryColorGroup(
            title: "button/label/neutral",
            swatches: [
                GallerySwatch("button.label.neutral.default", Color.ds.button.label.neutral.default),
                GallerySwatch("button.label.neutral.pressed", Color.ds.button.label.neutral.pressed),
                GallerySwatch("button.label.neutral.disabled", Color.ds.button.label.neutral.disabled),
            ]
        ),
        GalleryColorGroup(
            title: "button/label/ghost",
            swatches: [
                GallerySwatch("button.label.ghost.default", Color.ds.button.label.ghost.default),
                GallerySwatch("button.label.ghost.pressed", Color.ds.button.label.ghost.pressed),
                GallerySwatch("button.label.ghost.disabled", Color.ds.button.label.ghost.disabled),
            ]
        ),
        GalleryColorGroup(
            title: "button/label/text",
            swatches: [
                GallerySwatch("button.label.text.accent", Color.ds.button.label.text.accent),
                GallerySwatch("button.label.text.neutral", Color.ds.button.label.text.neutral),
            ]
        ),
        GalleryColorGroup(
            title: "overlay/dim",
            swatches: [
                GallerySwatch("overlay.dim._0", Color.ds.overlay.dim._0),
                GallerySwatch("overlay.dim._20", Color.ds.overlay.dim._20),
                GallerySwatch("overlay.dim._40", Color.ds.overlay.dim._40),
                GallerySwatch("overlay.dim._60", Color.ds.overlay.dim._60),
                GallerySwatch("overlay.dim._70", Color.ds.overlay.dim._70),
                GallerySwatch("overlay.dim._90", Color.ds.overlay.dim._90),
            ]
        ),
        GalleryColorGroup(
            title: "overlay/inverse",
            swatches: [
                GallerySwatch("overlay.inverse._10", Color.ds.overlay.inverse._10),
                GallerySwatch("overlay.inverse._20", Color.ds.overlay.inverse._20),
                GallerySwatch("overlay.inverse._40", Color.ds.overlay.inverse._40),
            ]
        ),
        GalleryColorGroup(
            title: "overlay/gray",
            swatches: [
                GallerySwatch("overlay.gray.default", Color.ds.overlay.gray.default),
                GallerySwatch("overlay.gray.plain", Color.ds.overlay.gray.plain),
            ]
        ),
    ]

    public static let textGroups: [GalleryTextGroup] = [
        GalleryTextGroup(
            title: "Title1",
            samples: [
                GalleryTextSample("title1.bold", TextStyle.ds.title1.bold),
            ]
        ),
        GalleryTextGroup(
            title: "Title2",
            samples: [
                GalleryTextSample("title2.regular", TextStyle.ds.title2.regular),
                GalleryTextSample("title2.semiBold", TextStyle.ds.title2.semiBold),
                GalleryTextSample("title2.bold", TextStyle.ds.title2.bold),
            ]
        ),
        GalleryTextGroup(
            title: "Title3",
            samples: [
                GalleryTextSample("title3.regular", TextStyle.ds.title3.regular),
                GalleryTextSample("title3.semiBold", TextStyle.ds.title3.semiBold),
            ]
        ),
        GalleryTextGroup(
            title: "Headline",
            samples: [
                GalleryTextSample("headline.regular", TextStyle.ds.headline.regular),
                GalleryTextSample("headline.medium", TextStyle.ds.headline.medium),
                GalleryTextSample("headline.semiBold", TextStyle.ds.headline.semiBold),
            ]
        ),
        GalleryTextGroup(
            title: "Body",
            samples: [
                GalleryTextSample("body.regular", TextStyle.ds.body.regular),
                GalleryTextSample("body.medium", TextStyle.ds.body.medium),
                GalleryTextSample("body.semiBold", TextStyle.ds.body.semiBold),
            ]
        ),
        GalleryTextGroup(
            title: "Subtext",
            samples: [
                GalleryTextSample("subtext.regular", TextStyle.ds.subtext.regular),
                GalleryTextSample("subtext.medium", TextStyle.ds.subtext.medium),
            ]
        ),
        GalleryTextGroup(
            title: "Caption1",
            samples: [
                GalleryTextSample("caption1.regular", TextStyle.ds.caption1.regular),
                GalleryTextSample("caption1.medium", TextStyle.ds.caption1.medium),
                GalleryTextSample("caption1.semiBold", TextStyle.ds.caption1.semiBold),
                GalleryTextSample("caption1.bold", TextStyle.ds.caption1.bold),
            ]
        ),
        GalleryTextGroup(
            title: "Caption2",
            samples: [
                GalleryTextSample("caption2.regular", TextStyle.ds.caption2.regular),
                GalleryTextSample("caption2.medium", TextStyle.ds.caption2.medium),
                GalleryTextSample("caption2.semiBold", TextStyle.ds.caption2.semiBold),
            ]
        ),
    ]

    /// 글자 스타일 21개를 묶음 순서대로 이은 목록.
    static let textSamples: [GalleryTextSample] = textGroups.flatMap(\.samples)
}
