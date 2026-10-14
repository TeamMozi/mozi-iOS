import Domain
import SharedDesignSystem
import SwiftUI
import ThirdParty

public struct PlaceSearchView: View {
    @Bindable public var store: StoreOf<PlaceSearchFeature>

    public init(store: StoreOf<PlaceSearchFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: CGFloat.ds.spacing.md) {
            DesignSearchField(text: $store.query, placeholder: "장소명으로 검색", style: .flat)
                .submitLabel(.search)
                .onSubmit {
                    store.send(.searchSubmitted)
                }
                .padding(.horizontal, CGFloat.ds.layout.margin)
                .padding(.top, PlaceSearchLayout.searchTopInset)
            content
        }
        .background(Color.ds.fill.neutral.default.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                DesignToolbarTitle("장소")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    store.send(.doneTapped)
                } label: {
                    DesignToolbarIcon(Image.ds.icon.check.outlined, isProminent: true)
                }
                .designToolbarProminent()
                .disabled(!store.canConfirm)
                .accessibilityLabel("완료")
            }
        }
        .screenStatus(store.screen) {
            store.send(.failureDismissed)
        }
    }

    @ViewBuilder
    private var content: some View {
        if !store.hasSearched {
            mapPlaceholder
        } else if store.results.isEmpty {
            // 문구는 시안에 없어 디자이너에게 요청했다. 임시 문구다
            DesignText(
                "검색 결과가 없어요",
                style: TextStyle.ds.body.medium,
                color: Color.ds.text.neutral.tertiary,
                alignment: .center
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            // 시안 「검색 후」(`5068:94374`): 지도 자리 아래에 「검색결과 N건」 판을 화면 바닥까지 붙인다
            VStack(spacing: 0) {
                mapPlaceholder
                resultPanel
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
    }

    /// 지도 자리. 카카오 지도는 별도 작업으로 뺐다. 화면 아래 끝까지 칠한다.
    private var mapPlaceholder: some View {
        Color.ds.fill.neutral.subtle
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(edges: .bottom)
            .accessibilityHidden(true)
    }

    private var resultPanel: some View {
        VStack(spacing: PlaceSearchLayout.countToListSpacing) {
            DesignText(
                "검색결과 \(store.results.count)건",
                style: TextStyle.ds.headline.semiBold,
                lineLimit: 1
            )
            .padding(PlaceSearchLayout.countInset)
            .frame(maxWidth: .infinity)
            .background(Color.ds.fill.neutral.raised)
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(store.results.enumerated()), id: \.offset) { index, place in
                        Button {
                            store.send(.placeTapped(index))
                        } label: {
                            DesignListRow(
                                place.name,
                                subtitle: place.address,
                                isSelected: store.selectedIndex == index,
                                style: .place
                            ) {
                                EmptyView()
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(height: listHeight)
        }
        .padding(.bottom, PlaceSearchLayout.panelBottomInset)
        .frame(maxWidth: .infinity)
        .background(Color.ds.fill.neutral.default)
    }

    /// 시안 목록은 줄 수만큼 늘다가 세 줄(192)에서 멈추고 안에서 넘긴다.
    private var listHeight: CGFloat {
        CGFloat(min(store.results.count, PlaceSearchLayout.maxVisibleRows)) * PlaceSearchLayout.rowHeight
    }
}

private enum PlaceSearchLayout {
    /// 시스템 내비게이션 막대 아래에서 검색 칸까지. 시안 검색 칸 위 끝 y114
    static let searchTopInset: CGFloat = 13
    /// 시안 「검색결과 N건」 띠 안쪽 여백 10(높이 42 = 10 + 22 + 10)
    static let countInset: CGFloat = 10
    /// 시안 띠와 목록 사이 2
    static let countToListSpacing: CGFloat = 2
    /// 시안 결과 판 아래 여백 36(판은 화면 바닥까지 닿는다). 목록 높이를 셀 때 쓰는 줄 높이는 공용 장소 줄(64)과 같다
    static let panelBottomInset: CGFloat = 36
    static let rowHeight: CGFloat = 64
    static let maxVisibleRows = 3
}
