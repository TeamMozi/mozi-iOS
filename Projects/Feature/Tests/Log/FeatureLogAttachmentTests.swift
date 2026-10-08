@testable import Feature
import ThirdParty
import XCTest

@MainActor
final class FeatureLogAttachmentTests: XCTestCase {
    func test_컨테이너_여덟은_자식이름과_함께_로그가_붙어_있다() {
        let mainTabChildren: Set<String> = ["shortform", "search", "chat", "myPage", "create"]
        let expected: [(body: Any, attachment: LoggedAttachment)] = [
            (
                RootFlowFeature().body,
                LoggedAttachment(scene: "RootFlow", children: ["login", "onboarding", "main"], wrapsStack: false)
            ),
            (
                OnboardingFlowFeature().body,
                LoggedAttachment(scene: "OnboardingFlow", children: ["profile"], wrapsStack: true)
            ),
            (
                MainTabFeature().body,
                LoggedAttachment(scene: "MainTab", children: mainTabChildren, wrapsStack: false)
            ),
            (
                ShortformFlowFeature().body,
                LoggedAttachment(scene: "ShortformFlow", children: ["placeholder"], wrapsStack: true)
            ),
            (
                SearchFlowFeature().body,
                LoggedAttachment(scene: "SearchFlow", children: ["placeholder"], wrapsStack: true)
            ),
            (
                ChatFlowFeature().body,
                LoggedAttachment(scene: "ChatFlow", children: ["placeholder"], wrapsStack: true)
            ),
            (
                MyPageFlowFeature().body,
                LoggedAttachment(scene: "MyPageFlow", children: ["myPage"], wrapsStack: true)
            ),
            (
                CreateFlowFeature().body,
                LoggedAttachment(scene: "CreateFlow", children: ["placeholder"], wrapsStack: true)
            ),
        ]

        for (body, attachment) in expected {
            XCTAssertEqual(LoggedAttachment.find(in: body), attachment, attachment.scene)
        }
    }

    func test_화면_여섯은_자식없이_로그가_붙어_있다() {
        let expected: [(body: Any, scene: String)] = [
            (LoginFeature().body, "Login"),
            (PlaceholderFeature().body, "Placeholder"),
            (MyPagePlaceholderFeature().body, "MyPagePlaceholder"),
            (ProfileSettingFeature().body, "ProfileSetting"),
            (InterestSettingFeature().body, "InterestSetting"),
            (NavigationSampleFeature().body, "NavigationSample"),
        ]

        for (body, scene) in expected {
            XCTAssertEqual(
                LoggedAttachment.find(in: body),
                LoggedAttachment(scene: scene, children: [], wrapsStack: false),
                scene
            )
        }
    }

    func test_RootFeature에는_로그가_붙지_않는다() {
        XCTAssertNil(LoggedAttachment.find(in: RootFeature().body))
    }
}

/// body 안의 `.logged` 래퍼가 받은 값. `wrapsStack` 은 `.forEach` 까지 감쌌는지다
private struct LoggedAttachment: Equatable {
    var scene: String
    var children: Set<String>
    var wrapsStack: Bool

    /// body 를 Mirror 로 넓이 우선으로 훑어 맨 바깥 `FeatureLogReducer` 를 찾는다
    static func find(in body: Any) -> LoggedAttachment? {
        var queue: [(value: Any, depth: Int)] = [(body, 0)]
        while queue.isEmpty == false {
            let (value, depth) = queue.removeFirst()
            let mirror = Mirror(reflecting: value)
            if String(describing: type(of: value)).hasPrefix("FeatureLogReducer<") {
                return attachment(from: mirror)
            }
            // 자식 리듀서의 의존성 값까지 내려가지 않도록 깊이를 자른다
            guard depth < 4 else {
                continue
            }
            queue += mirror.children.map { ($0.value, depth + 1) }
        }
        return nil
    }

    private static func attachment(from mirror: Mirror) -> LoggedAttachment? {
        var fields: [String: Any] = [:]
        for child in mirror.children {
            if let label = child.label {
                fields[label] = child.value
            }
        }
        guard let scene = fields["scene"] as? String,
              let children = fields["children"] as? Set<String>,
              let base = fields["base"]
        else {
            return nil
        }
        let wrapsStack = String(describing: type(of: base)).hasPrefix("_StackReducer<")
        return LoggedAttachment(scene: scene, children: children, wrapsStack: wrapsStack)
    }
}
