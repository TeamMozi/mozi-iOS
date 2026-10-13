import Domain
import SharedDesignSystem
import SwiftUI

/// 모임장·멤버만 보는 스냅 포인트 목록. 비어 있으면 구간을 그리지 않는다.
struct MeetingDetailSnapPointSection: View {
    let snapPoints: [SnapPoint]

    var body: some View {
        if !snapPoints.isEmpty {
            VStack(alignment: .leading, spacing: CGFloat.ds.spacing.sm) {
                MeetingDetailSectionTitle(title: "스냅 포인트")
                ForEach(snapPoints, id: \.id) { snapPoint in
                    HStack(alignment: .firstTextBaseline, spacing: CGFloat.ds.spacing.xs) {
                        DesignText("✱", style: TextStyle.ds.body.regular, color: Color.ds.text.neutral.subtle)
                        DesignText(
                            snapPoint.name,
                            style: TextStyle.ds.body.regular,
                            color: Color.ds.text.neutral.secondary
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, CGFloat.ds.layout.margin)
        }
    }
}
