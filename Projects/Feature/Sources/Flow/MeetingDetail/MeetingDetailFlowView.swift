import SwiftUI
import ThirdParty

public struct MeetingDetailFlowView: View {
    @Bindable public var store: StoreOf<MeetingDetailFlowFeature>

    public init(store: StoreOf<MeetingDetailFlowFeature>) {
        self.store = store
    }

    public var body: some View {
        // 첫 화면 위 쌓기는 `path` 가 소유한다. 뒤로 가기는 `.path(.popFrom)` 으로 들어온다
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            root
        } destination: { routeStore in
            MeetingDetailRouteView(store: routeStore)
        }
        // 사이드바가 떠 있는 동안 뒤의 상세(막대·툴바 포함)를 흐린다. 사이드바 화면은 그 위에 `overlay/dim/90` 만 칠한다.
        // 흐림은 그리기만 바꾸므로 상세의 스크롤 위치와 상태는 그대로다. 덮개가 오르내리는 동안 함께 바뀐다.
        // `opaque: true` 라 화면 가장자리가 투명하게 빠지지 않고 끝 화소를 늘려 흐린다.
        .animation(MeetingDetailFlowLayout.backdropBlurAnimation) { content in
            content.blur(
                radius: store.management == nil ? 0 : MeetingDetailFlowLayout.backdropBlurRadius,
                opaque: true
            )
        }
        // 사이드바는 상세를 덮는다. 덮개 바탕을 비워 뒤의 흐린 상세가 비치게 한다
        .fullScreenCover(item: $store.scope(state: \.management, action: \.management)) { managementStore in
            NavigationStack(path: $store.scope(state: \.managementPath, action: \.managementPath)) {
                MeetingManagementView(store: managementStore)
            } destination: { routeStore in
                // 멤버 관리는 `overlay/dim/90` 만 칠한다. 덮개 안에서는 쌓인 화면의 바탕도 비워 뒤의 흐린 상세가 비치게 한다
                MeetingDetailRouteView(store: routeStore)
                    .containerBackground(.clear, for: .navigation)
            }
            .presentationBackground(.clear)
        }
    }

    @ViewBuilder
    private var root: some View {
        if let detailStore = store.scope(state: \.detail, action: \.detail) {
            MeetingDetailView(store: detailStore)
        } else if let widgetStore = store.scope(state: \.widget, action: \.widget) {
            MeetingWidgetView(store: widgetStore)
        }
    }
}

private enum MeetingDetailFlowLayout {
    /// 시안 사이드바 BACKGROUND_BLUR 40 의 절반. Figma 반경은 가우스 표준편차의 두 배, SwiftUI 반경은 표준편차다
    /// (회차 카드 날짜 띠도 같은 대응으로 Figma 8 → 4 를 쓴다)
    static let backdropBlurRadius: CGFloat = 20
    /// 덮개(`fullScreenCover`)가 오르내리는 시스템 애니메이션 길이에 맞춘다
    static let backdropBlurAnimation: Animation = .smooth(duration: 0.5)
}

/// 두 쌓기(위젯 위, 사이드바 덮개 안)가 함께 그리는 쌓인 화면
struct MeetingDetailRouteView: View {
    let store: StoreOf<MeetingDetailFlowFeature.Route>

    var body: some View {
        switch store.case {
        case let .memberManagement(memberStore):
            MemberManagementView(store: memberStore)
        case let .snapPointSetting(snapPointStore):
            SnapPointSettingView(store: snapPointStore)
        }
    }
}
