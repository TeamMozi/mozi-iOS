import SharedDesignSystem
import SwiftUI

/// 디자인 시스템 화면 하나의 틀. 제목과 모드 전환 아래에 내용을 쌓는 스크롤 화면이다.
/// 모드 전환은 이 틀 안에만 걸린다.
struct GalleryPage<Content: View>: View {
    private let screen: GalleryScreen
    private let content: Content

    @Environment(\.colorScheme) private var systemColorScheme
    @State private var appearance: GalleryAppearance = .system

    init(_ screen: GalleryScreen, @ViewBuilder content: () -> Content) {
        self.screen = screen
        self.content = content()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CGFloat.ds.spacing.xl) {
                DesignText(screen.title, style: TextStyle.ds.title2.bold)
                appearancePicker
                content
            }
            .padding(.horizontal, CGFloat.ds.layout.margin)
            .padding(.top, CGFloat.ds.spacing.lg)
            .padding(.bottom, CGFloat.ds.spacing.xxl)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.ds.fill.neutral.default.ignoresSafeArea())
        .environment(\.colorScheme, appearance.colorScheme ?? systemColorScheme)
    }

    private var appearancePicker: some View {
        Picker("화면 모드", selection: $appearance) {
            ForEach(GalleryAppearance.allCases) { option in
                Text(option.title).tag(option)
            }
        }
        .pickerStyle(.segmented)
    }
}

/// 디자인 시스템 화면 안의 구간. 제목 아래에 내용을 쌓는다.
struct GallerySection<Content: View>: View {
    private let title: String
    private let content: Content

    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: CGFloat.ds.spacing.sm) {
            DesignText(title, style: TextStyle.ds.title3.semiBold)
            content
        }
    }
}

/// 디자인 시스템 화면 위 모드 전환. 시스템은 기기 모드를 덮어쓰지 않는다.
enum GalleryAppearance: String, CaseIterable, Identifiable {
    case system
    case dark
    case light

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: "시스템"
        case .dark: "다크"
        case .light: "라이트"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .dark: .dark
        case .light: .light
        }
    }
}
