import Domain
import SwiftUI
import ThirdParty

public struct CreateMeetingFlowView: View {
    @Bindable public var store: StoreOf<CreateMeetingFlowFeature>

    public init(store: StoreOf<CreateMeetingFlowFeature>) {
        self.store = store
    }

    public var body: some View {
        // 시트 안 화면 스택은 CreateMeetingFlowFeature 의 path 가 소유한다. 뒤로 가기는 `.path(.popFrom)` 으로 들어온다
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            MeetingFormView(store: store.scope(state: \.form, action: \.form))
        } destination: { routeStore in
            switch routeStore.case {
            case let .previousMeeting(previousStore):
                PreviousMeetingView(store: previousStore)
            case let .placeSearch(placeStore):
                PlaceSearchView(store: placeStore)
            case let .poster(posterStore):
                PosterView(store: posterStore)
            case let .seriesInfo(seriesStore):
                SeriesInfoView(store: seriesStore)
            }
        }
    }
}

// MARK: - Preview

#Preview("CreateMeetingFlow") {
    CreateMeetingFlowView(
        store: Store(initialState: CreateMeetingFlowFeature.State()) {
            CreateMeetingFlowFeature()
        } withDependencies: {
            $0.meetingClient = .previewValue
            $0.seriesClient = .previewValue
            $0.placeClient = .previewValue
        }
    )
}
