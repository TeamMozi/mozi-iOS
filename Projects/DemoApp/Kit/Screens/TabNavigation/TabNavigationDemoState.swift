import Feature
import ThirdParty

/// 숏폼 「탭 안 이동」 데모 상태 셋. 고른 수만큼 견본을 쌓은 채로 숏폼 Flow 를 시작한다.
public enum TabNavigationDemoState: String, CaseIterable, Hashable, Sendable {
    case root
    case oneSample
    case twoSamples

    /// 상태 시트의 줄 이름.
    public var title: String {
        switch self {
        case .root: "첫 화면"
        case .oneSample: "견본 1장"
        case .twoSamples: "견본 2장"
        }
    }

    /// 데모 버튼에 적는 짧은 이름.
    public var shortTitle: String {
        switch self {
        case .root: "처음"
        case .oneSample: "1장"
        case .twoSamples: "2장"
        }
    }

    var sampleCount: Int {
        switch self {
        case .root: 0
        case .oneSample: 1
        case .twoSamples: 2
        }
    }

    /// 이 상태로 시작하는 숏폼 Flow 상태. 견본은 1부터 번호를 매겨 쌓는다.
    public var shortformState: ShortformFlowFeature.State {
        let samples = (0..<sampleCount).map { index in
            ShortformFlowFeature.Route.State.sample(NavigationSampleFeature.State(number: index + 1))
        }
        return ShortformFlowFeature.State(path: StackState(samples))
    }
}
