import Domain
import Feature
import MoziDemoKit
import SwiftUI
import ThirdParty

/// 위젯 화면으로 시작하는 모임 상세 흐름을 고른 상태로 띄운다. 상태를 바꾸면 가짜 서버까지 처음부터 다시 만든다.
///
/// 흐름이 자기 NavigationStack 을 가지므로 `DemoRootView` 가 전체 화면으로 덮어 띄운다.
struct MeetingWidgetDemoScreen: View {
    let onExit: () -> Void

    @State private var demoState: MeetingWidgetDemoState
    @State private var store: StoreOf<DemoMeetingDetailFeature>
    @State private var generation = 0

    init(onExit: @escaping () -> Void) {
        self.onExit = onExit
        _demoState = State(initialValue: .beforeNotification)
        _store = State(initialValue: Self.makeStore(for: .beforeNotification))
    }

    var body: some View {
        MeetingDetailFlowView(store: store.scope(state: \.flow, action: \.flow))
            .id(generation)
            .onChange(of: store.isFinished) { _, isFinished in
                if isFinished {
                    onExit()
                }
            }
            .demoMenu(
                shortLabel: demoState.shortTitle,
                options: MeetingWidgetDemoState.allCases.map { DemoMenuOption(id: $0.rawValue, title: $0.title) },
                selectedID: demoState.rawValue,
                onSelect: { id in
                    select(MeetingWidgetDemoState(rawValue: id) ?? .beforeNotification)
                },
                onExit: onExit
            )
    }

    private func select(_ state: MeetingWidgetDemoState) {
        demoState = state
        store = Self.makeStore(for: state)
        generation += 1
    }

    private static func makeStore(for state: MeetingWidgetDemoState) -> StoreOf<DemoMeetingDetailFeature> {
        let backend = MeetingDetailDemoBackend(
            sentSnapPointCount: state.sentSnapPointCount,
            initialStatus: state.initialMeetingStatus,
            photoURL: DemoPhoto.url
        )
        return Store(
            initialState: DemoMeetingDetailFeature.State(
                flow: MeetingDetailFlowFeature.State(widgetOf: MeetingDetailDemoBackend.meetingID)
            )
        ) {
            DemoMeetingDetailFeature()
        } withDependencies: {
            $0.meetingClient = MeetingDetailDemoClients.meetingClient(backend, as: .host)
            $0.snapPointClient = MeetingDetailDemoClients.snapPointClient(backend)
            $0.seriesClient = MeetingDetailDemoClients.seriesClient(photoURL: DemoPhoto.url)
        }
    }
}
