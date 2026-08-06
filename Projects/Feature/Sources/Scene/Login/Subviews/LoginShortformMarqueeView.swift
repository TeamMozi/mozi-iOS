import SharedDesignSystem
import SwiftUI

struct LoginShortformMarqueeView: View {
    private let images: [Image]
    private let speedPointsPerSecond: CGFloat
    @State private var startDate = Date()

    init(
        images: [Image] = LoginShortformMarqueeView.defaultImages,
        speedPointsPerSecond: CGFloat = 32
    ) {
        self.images = images
        self.speedPointsPerSecond = speedPointsPerSecond
    }

    var body: some View {
        GeometryReader { proxy in
            let sequenceWidth = Self.sequenceWidth(cardCount: images.count)
            let copies = max(3, Int(ceil((proxy.size.width + sequenceWidth) / max(sequenceWidth, 1))) + 1)

            TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: false)) { context in
                let elapsed = context.date.timeIntervalSince(startDate)
                let traveled = CGFloat(elapsed) * speedPointsPerSecond
                let offset = sequenceWidth == 0
                    ? 0
                    : -traveled.truncatingRemainder(dividingBy: sequenceWidth)

                HStack(spacing: Self.cardGap) {
                    ForEach(0..<(images.count * copies), id: \.self) { index in
                        card(images[index % images.count])
                    }
                }
                .offset(x: offset)
            }
        }
        .frame(height: Self.cardSize.height)
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipped()
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func card(_ image: Image) -> some View {
        image
            .resizable()
            .scaledToFill()
            .frame(width: Self.cardSize.width, height: Self.cardSize.height)
            .clipped()
            .overlay {
                Color.black.opacity(CGFloat.ds.dim.heavy)
            }
            .clipShape(
                RoundedRectangle(cornerRadius: CGFloat.ds.radius.md, style: .continuous)
            )
    }
}

extension LoginShortformMarqueeView {
    static let cardSize = CGSize(width: 118, height: 172)
    static let cardGap: CGFloat = 12

    static var defaultImages: [Image] {
        [
            SharedDesignSystemAsset.loginShortform01.swiftUIImage,
            SharedDesignSystemAsset.loginShortform02.swiftUIImage,
            SharedDesignSystemAsset.loginShortform03.swiftUIImage,
            SharedDesignSystemAsset.loginShortform04.swiftUIImage,
        ]
    }

    static func sequenceWidth(cardCount: Int) -> CGFloat {
        guard cardCount > 0 else { return 0 }
        let cardsWidth = CGFloat(cardCount) * cardSize.width
        // 시퀀스 경계에서도 카드 간격이 유지되도록 trailing gap 포함
        let gapsWidth = CGFloat(cardCount) * cardGap
        return cardsWidth + gapsWidth
    }
}
