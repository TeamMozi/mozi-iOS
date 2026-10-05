import SharedDesignSystem
import SwiftUI
import ThirdParty

public struct NavigationSampleView: View {
    @Bindable public var store: StoreOf<NavigationSampleFeature>

    public init(store: StoreOf<NavigationSampleFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: CGFloat.ds.spacing.md) {
            Spacer()

            DesignText(
                store.title,
                style: TextStyle.ds.title2.bold,
                color: Color.ds.text.neutral.primary,
                alignment: .center
            )

            Spacer()

            Button {
                store.send(.nextTapped)
            } label: {
                Text("다음")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.main)
            .controlSize(.large)
            .padding(.horizontal, CGFloat.ds.layout.margin)
            .padding(.bottom, CGFloat.ds.spacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.ds.fill.neutral.default.ignoresSafeArea())
    }
}

// MARK: - Preview

#Preview("NavigationSample") {
    NavigationSampleView(
        store: Store(initialState: NavigationSampleFeature.State(number: 1)) {
            NavigationSampleFeature()
        }
    )
}
