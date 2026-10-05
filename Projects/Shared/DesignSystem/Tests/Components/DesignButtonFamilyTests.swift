@testable import SharedDesignSystem
import SwiftUI
import XCTest

final class DesignButtonFamilyTests: XCTestCase {
    // MARK: - 글자 버튼

    func test_글자_neutral은_text_neutral_색_아이콘_14다() {
        assertPalette(
            DesignTextButtonResolver.palette(kind: .neutral, state: .default),
            background: nil,
            content: (dark: 0x7A7887FF, light: 0xB0AFB5FF)
        )
        XCTAssertEqual(DesignTextButtonResolver.iconSize(kind: .neutral), 14)
    }

    func test_글자_accent는_text_accent_색_아이콘_18이다() {
        assertPalette(
            DesignTextButtonResolver.palette(kind: .accent, state: .default),
            background: nil,
            content: (dark: 0xF5FE76FF, light: 0xF29407FF)
        )
        XCTAssertEqual(DesignTextButtonResolver.iconSize(kind: .accent), 18)
    }

    func test_글자는_눌리면_0점88_비활성은_그대로다() {
        assertPalette(
            DesignTextButtonResolver.palette(kind: .accent, state: .pressed),
            background: nil,
            content: (dark: 0xF5FE76FF, light: 0xF29407FF),
            opacity: 0.88
        )
        assertPalette(
            DesignTextButtonResolver.palette(kind: .accent, state: .disabled),
            background: nil,
            content: (dark: 0xF5FE76FF, light: 0xF29407FF)
        )
    }

    func test_글자는_높이_18_Caption1_Medium이다() {
        XCTAssertEqual(DesignTextButtonResolver.height, 18)
        XCTAssertEqual(DesignTextButtonResolver.textStyle, TextStyle.ds.caption1.medium)
    }

    // MARK: - 액션 버튼

    func test_액션_controlSize_small_이하는_s_나머지는_m이다() {
        XCTAssertEqual(DesignActionButtonSize(.mini), .s)
        XCTAssertEqual(DesignActionButtonSize(.small), .s)
        XCTAssertEqual(DesignActionButtonSize(.regular), .m)
        XCTAssertEqual(DesignActionButtonSize(.large), .m)
        XCTAssertEqual(DesignActionButtonSize(.extraLarge), .m)
    }

    func test_액션_m은_원_52_Headline_Medium이다() {
        let size = DesignActionButtonSize.m
        XCTAssertEqual(size.circleDiameter, 52)
        XCTAssertEqual(size.iconSize, 24)
        XCTAssertEqual(size.spacing, 8)
        XCTAssertEqual(size.textStyle, TextStyle.ds.headline.medium)
        assertTheme(size.titleColor, dark: 0xFCFCFCFF, light: 0x0E0E11FF)
    }

    func test_액션_s는_원_36_Caption1_Medium이다() {
        let size = DesignActionButtonSize.s
        XCTAssertEqual(size.circleDiameter, 36)
        XCTAssertEqual(size.iconSize, 24)
        XCTAssertEqual(size.spacing, 8)
        XCTAssertEqual(size.textStyle, TextStyle.ds.caption1.medium)
        assertTheme(size.titleColor, dark: 0xB0AFB5FF, light: 0x7A7887FF)
    }

    func test_액션_neutral은_subtle_원에_primary_아이콘이다() {
        assertPalette(
            DesignActionButtonResolver.palette(kind: .neutral, state: .default),
            background: (dark: 0x18181CFF, light: 0xF2F2F3FF),
            content: (dark: 0xFCFCFCFF, light: 0x0E0E11FF)
        )
    }

    func test_액션_accent는_원시_색이고_두_모드가_같다() {
        assertPalette(
            DesignActionButtonResolver.palette(kind: .accent, state: .default),
            background: (dark: 0xF5FE76FF, light: 0xF5FE76FF),
            content: (dark: 0x000000FF, light: 0x000000FF)
        )
    }

    func test_액션은_눌리면_0점88_비활성은_그대로다() {
        assertPalette(
            DesignActionButtonResolver.palette(kind: .accent, state: .pressed),
            background: (dark: 0xF5FE76FF, light: 0xF5FE76FF),
            content: (dark: 0x000000FF, light: 0x000000FF),
            opacity: 0.88
        )
        assertPalette(
            DesignActionButtonResolver.palette(kind: .accent, state: .disabled),
            background: (dark: 0xF5FE76FF, light: 0xF5FE76FF),
            content: (dark: 0x000000FF, light: 0x000000FF)
        )
    }

    @MainActor
    func test_액션_글자가_줄_높이를_차지해_높이가_82와_62다() {
        let medium = actionNaturalHeight(controlSize: .regular)
        let small = actionNaturalHeight(controlSize: .small)

        XCTAssertEqual(medium, 82, accuracy: 0.5)
        XCTAssertEqual(small, 62, accuracy: 0.5)
    }

    // MARK: - Shortcut

    func test_Shortcut_circle은_48_원이고_tile은_44_반경_12다() {
        XCTAssertEqual(DesignShortcutButtonResolver.side(kind: .circle), 48)
        XCTAssertEqual(DesignShortcutButtonResolver.side(kind: .tile), 44)
        XCTAssertEqual(DesignShortcutButtonResolver.tileCornerRadius, 12)
        XCTAssertEqual(DesignShortcutButtonResolver.iconSize, 24)
    }

    func test_Shortcut_circle_기본은_muted_바탕이다() {
        assertPalette(
            DesignShortcutButtonResolver.palette(kind: .circle, state: .default),
            background: (dark: 0x34333EFF, light: 0xDFDFE2FF),
            content: (dark: 0xFCFCFCFF, light: 0x0E0E11FF)
        )
    }

    func test_Shortcut_tile_기본은_raised_바탕이다() {
        assertPalette(
            DesignShortcutButtonResolver.palette(kind: .tile, state: .default),
            background: (dark: 0x202027FF, light: 0xEAEAEBFF),
            content: (dark: 0xFCFCFCFF, light: 0x0E0E11FF)
        )
    }

    func test_Shortcut_눌림은_기본_색에_0점88이다() {
        assertPalette(
            DesignShortcutButtonResolver.palette(kind: .tile, state: .pressed),
            background: (dark: 0x202027FF, light: 0xEAEAEBFF),
            content: (dark: 0xFCFCFCFF, light: 0x0E0E11FF),
            opacity: 0.88
        )
    }

    func test_Shortcut_비활성은_subtle_바탕에_faint_아이콘이다() {
        for kind in [DesignShortcutButtonKind.circle, .tile] {
            assertPalette(
                DesignShortcutButtonResolver.palette(kind: kind, state: .disabled),
                background: (dark: 0x18181CFF, light: 0xF2F2F3FF),
                content: (dark: 0x484753FF, light: 0xCACACEFF)
            )
        }
    }

    @MainActor
    func test_Shortcut은_VoiceOver가_제목을_읽는다() {
        for kind in [DesignShortcutButtonKind.circle, .tile] {
            for isDisabled in [false, true] {
                let button = Button("영상", icon: Image.ds.icon.video.filled) {}
                    .buttonStyle(.shortcut(kind))
                    .disabled(isDisabled)
                XCTAssertEqual(buttonAccessibilityLabels(button), ["영상"], "\(kind) 비활성 \(isDisabled)")
            }
        }
    }

    @MainActor
    func test_기본과_글자_버튼은_제목을_한_번만_읽는다() {
        let main = Button("추가", icon: Image.ds.icon.plus.outlined) {}
            .buttonStyle(.main)
        let text = Button("더보기", icon: Image.ds.icon.moreHorizontal.outlined) {}
            .buttonStyle(.textButton(.neutral))

        XCTAssertEqual(buttonAccessibilityLabels(main), ["추가"])
        XCTAssertEqual(buttonAccessibilityLabels(text), ["더보기"])
    }

    // MARK: - 알약 글자 버튼

    func test_알약_기본과_눌림은_primary_글자에_유리다() {
        for state in [DesignButtonState.default, .pressed] {
            assertPalette(
                DesignPillButtonResolver.palette(state: state),
                background: nil,
                content: (dark: 0xFCFCFCFF, light: 0x0E0E11FF)
            )
            XCTAssertTrue(DesignPillButtonResolver.usesGlass(state: state))
        }
    }

    func test_알약_비활성은_subtle_글자에_유리가_없다() {
        assertPalette(
            DesignPillButtonResolver.palette(state: .disabled),
            background: nil,
            content: (dark: 0x7A7887FF, light: 0xB0AFB5FF)
        )
        XCTAssertFalse(DesignPillButtonResolver.usesGlass(state: .disabled))
    }

    func test_알약은_높이_32_여백_12_Subtext_Medium이다() {
        XCTAssertEqual(DesignPillButtonResolver.height, 32)
        XCTAssertEqual(DesignPillButtonResolver.horizontalPadding, 12)
        XCTAssertEqual(DesignPillButtonResolver.textStyle, TextStyle.ds.subtext.medium)
    }

    // MARK: - 짧은 이름

    @MainActor
    func test_짧은_이름이_종류를_고른다() {
        XCTAssertEqual(DesignTextButtonStyle.textButton(.accent).kind, .accent)
        XCTAssertEqual(DesignTextButtonStyle.textButton(.neutral).kind, .neutral)
        XCTAssertEqual(DesignActionButtonStyle.action(.accent).kind, .accent)
        XCTAssertEqual(DesignActionButtonStyle.action(.neutral).kind, .neutral)
        XCTAssertEqual(DesignShortcutButtonStyle.shortcut(.circle).kind, .circle)
        XCTAssertEqual(DesignShortcutButtonStyle.shortcut(.tile).kind, .tile)
        XCTAssertTrue(type(of: DesignPillButtonStyle.pill) == DesignPillButtonStyle.self)
    }
}

private extension DesignButtonFamilyTests {
    @MainActor
    func actionNaturalHeight(controlSize: ControlSize) -> CGFloat {
        let button = Button("만들기", icon: Image.ds.icon.close.outlined) {}
            .buttonStyle(.action(.accent))
            .controlSize(controlSize)
            .dynamicTypeSize(.large)
        return UIHostingController(rootView: button)
            .sizeThatFits(in: UIView.layoutFittingExpandedSize)
            .height
    }

    /// 화면 밖 창에 올린 뒤 버튼 특성을 가진 접근성 요소의 라벨을 모은다.
    /// 요소가 하나라도 생길 때까지 0.05초 간격으로 다시 보고, 2초가 넘으면 그때까지 모은 결과를 돌려준다.
    @MainActor
    func buttonAccessibilityLabels(_ view: some View) -> [String?] {
        if let failure = Self.applicationAccessibilityFailure {
            XCTFail(failure)
        }
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        let host = UIHostingController(rootView: view.dynamicTypeSize(.large))
        window.rootViewController = host
        window.makeKeyAndVisible()
        host.view.frame = window.bounds
        host.view.layoutIfNeeded()
        defer {
            window.isHidden = true
            window.rootViewController = nil
        }
        let deadline = Date().addingTimeInterval(2)
        var labels: [String?] = []
        repeat {
            RunLoop.main.run(until: Date().addingTimeInterval(0.05))
            var elements: [NSObject] = []
            collectAccessibilityElements(host.view, into: &elements, depth: 0)
            labels = elements
                .filter { $0.accessibilityTraits.contains(.button) }
                .map(\.accessibilityLabel)
        } while labels.isEmpty && Date() < deadline
        return labels
    }

    /// 호스트 앱 없는 테스트는 새 시뮬레이터에서 앱 접근성이 꺼져 있어 SwiftUI 가 접근성 트리를 만들지 않는다.
    /// 그래서 공개 API 가 없는 libAccessibility 의 함수로 테스트 프로세스에서 한 번 켠다. 실패하면 이유를 돌려준다.
    static let applicationAccessibilityFailure: String? = {
        typealias SetEnabled = @convention(c) (Bool) -> Void
        typealias IsEnabled = @convention(c) () -> Bool
        let path = "/usr/lib/libAccessibility.dylib"
        guard let handle = dlopen(path, RTLD_NOW) else {
            return "\(path) 를 열지 못해 앱 접근성을 켤 수 없다"
        }
        guard let setSymbol = dlsym(handle, "_AXSApplicationAccessibilitySetEnabled"),
              let getSymbol = dlsym(handle, "_AXSApplicationAccessibilityEnabled") else {
            return "_AXSApplicationAccessibilitySetEnabled / _AXSApplicationAccessibilityEnabled 를 찾지 못했다"
        }
        unsafeBitCast(setSymbol, to: SetEnabled.self)(true)
        guard unsafeBitCast(getSymbol, to: IsEnabled.self)() else {
            return "_AXSApplicationAccessibilitySetEnabled(true) 뒤에도 앱 접근성이 꺼져 있다"
        }
        return nil
    }()

    @MainActor
    func collectAccessibilityElements(_ object: NSObject, into found: inout [NSObject], depth: Int) {
        guard depth < 12 else { return }
        if object.isAccessibilityElement {
            found.append(object)
        }
        var children: [NSObject] = []
        if let elements = object.accessibilityElements as? [NSObject] {
            children.append(contentsOf: elements)
        } else {
            let count = object.accessibilityElementCount()
            if count != NSNotFound, count > 0 {
                children.append(contentsOf: (0..<count).compactMap { object.accessibilityElement(at: $0) as? NSObject })
            }
        }
        if let view = object as? UIView {
            children.append(contentsOf: view.subviews)
        }
        for child in children {
            collectAccessibilityElements(child, into: &found, depth: depth + 1)
        }
    }
}
