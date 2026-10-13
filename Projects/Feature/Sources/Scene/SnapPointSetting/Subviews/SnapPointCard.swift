import Domain
import SharedDesignSystem
import SwiftUI

/// 등록된 스냅 포인트 카드. `•••` 는 시안이 없어 iOS 기본 메뉴다.
/// 종료된 모임이면 그리지 않고(`showsMenu`), 요청 중에는 그린 채 누르지 못하게 한다(`isMenuEnabled`).
struct SnapPointCard: View {
    let snapPoint: SnapPoint
    let showsMenu: Bool
    let isMenuEnabled: Bool
    let canDelete: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: SnapPointCardMetrics.contentSpacing) {
            SnapPointCardText(name: snapPoint.name, message: snapPoint.notificationMessage)
            if showsMenu {
                Menu {
                    Button("수정", action: onEdit)
                    Button("삭제", role: .destructive, action: onDelete)
                        .disabled(!canDelete)
                } label: {
                    Image.ds.icon.moreHorizontal.outlined
                        .iconSize(CGFloat.ds.iconSize._24)
                        .foregroundStyle(Color.ds.text.neutral.primary)
                }
                .disabled(!isMenuEnabled)
                .accessibilityLabel("더보기")
            }
        }
        .padding(.vertical, SnapPointCardMetrics.verticalPadding)
        .padding(.horizontal, SnapPointCardMetrics.horizontalPadding)
        .overlay {
            RoundedRectangle(cornerRadius: CGFloat.ds.radius._16)
                .strokeBorder(Color.ds.border.neutral._10, lineWidth: CGFloat.ds.border.thin)
        }
    }
}

/// 「직접 추가 +」. 시안 `SnapPoint` 의 add 변형(`2973:34678`)
struct SnapPointAddButton: View {
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: SnapPointCardMetrics.addIconSpacing) {
                DesignText("직접 추가", style: TextStyle.ds.headline.semiBold, color: Color.ds.text.neutral.tertiary)
                Image.ds.icon.plus.filled
                    .iconSize(CGFloat.ds.iconSize._18)
                    .foregroundStyle(Color.ds.text.neutral.tertiary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: SnapPointCardMetrics.addHeight)
            .overlay {
                RoundedRectangle(cornerRadius: CGFloat.ds.radius._16)
                    .strokeBorder(Color.ds.border.neutral._20, lineWidth: CGFloat.ds.border.thin)
            }
            .contentShape(RoundedRectangle(cornerRadius: CGFloat.ds.radius._16))
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

/// 「추천 스냅포인트」 제목과 추천 카드. 「더보기 >」 는 보이기만 한다.
struct SnapPointRecommendationSection: View {
    let recommendations: [SnapPointDraft]
    let isEnabled: Bool
    let onSelect: (SnapPointDraft) -> Void

    var body: some View {
        VStack(spacing: SnapPointCardMetrics.sectionSpacing) {
            HStack(spacing: CGFloat.ds.spacing.xs) {
                DesignText("추천 스냅포인트", style: TextStyle.ds.body.semiBold)
                Spacer(minLength: 0)
                Button("더보기", icon: Image.ds.icon.chevron.right) {}
                    .buttonStyle(.textButton(.neutral))
                    .disabled(true)
            }
            VStack(spacing: SnapPointCardMetrics.sectionSpacing) {
                ForEach(recommendations, id: \.name) { recommendation in
                    Button {
                        onSelect(recommendation)
                    } label: {
                        SnapPointCardText(name: recommendation.name, message: recommendation.notificationMessage)
                            .padding(.vertical, SnapPointCardMetrics.verticalPadding)
                            .padding(.leading, SnapPointCardMetrics.horizontalPadding)
                            .padding(.trailing, SnapPointCardMetrics.recommendationTrailingPadding)
                            .background(
                                Color.ds.fill.neutral.subtle,
                                in: RoundedRectangle(cornerRadius: CGFloat.ds.radius._16)
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(!isEnabled)
                }
            }
        }
    }
}

/// 카드 안 이름과 알림 메시지 두 줄
private struct SnapPointCardText: View {
    let name: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: SnapPointCardMetrics.textSpacing) {
            DesignText(name, style: TextStyle.ds.headline.semiBold, color: Color.ds.text.neutral.secondary)
            DesignText(message, style: TextStyle.ds.caption1.regular, color: Color.ds.text.neutral.tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// 시안 컴포넌트 `SnapPoint`(`2973:34679`) 값과 추천 묶음(`Frame 1739337466`) 간격
private enum SnapPointCardMetrics {
    static let verticalPadding: CGFloat = CGFloat.ds.spacing.md
    static let horizontalPadding: CGFloat = 14
    static let recommendationTrailingPadding: CGFloat = 10
    static let contentSpacing: CGFloat = 2
    static let textSpacing: CGFloat = 2
    static let addIconSpacing: CGFloat = CGFloat.ds.spacing.xs
    static let addHeight: CGFloat = 60
    static let sectionSpacing: CGFloat = CGFloat.ds.spacing.md
}
