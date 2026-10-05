import SwiftUI

/// 모집 상태 드롭다운. 접힌 알약을 누르면 iOS 기본 메뉴가 뜬다.
/// 지금 값은 쓰는 쪽이 넘기고, 고르면 `onSelect` 가 불린다. 메뉴 항목 글자색은 시스템이 정한다.
public struct DesignStatusMenu: View {
    private let status: DesignRecruitStatus
    private let onSelect: @MainActor (DesignRecruitStatus) -> Void

    public init(status: DesignRecruitStatus, onSelect: @escaping @MainActor (DesignRecruitStatus) -> Void) {
        self.status = status
        self.onSelect = onSelect
    }

    public var body: some View {
        Menu {
            DesignMenuOptions(
                options: DesignRecruitStatus.allCases,
                selected: status,
                title: \.title,
                onSelect: onSelect
            )
        } label: {
            collapsedPill
        }
        .menuIndicator(.hidden)
        .accessibilityLabel("모집 상태")
        .accessibilityValue(status.title)
    }

    private var collapsedPill: some View {
        HStack(spacing: DesignStatusMenuMetrics.labelToChevronSpacing) {
            DesignText(
                status.title,
                style: TextStyle.ds.caption1.semiBold,
                color: DesignStatusMenuStyleResolver.text(for: status).color,
                lineLimit: 1
            )
            .frame(width: DesignStatusMenuMetrics.labelWidth, alignment: .leading)
            Image.ds.icon.chevron.down
                .iconSize(DesignStatusMenuMetrics.chevronSize)
                .foregroundStyle(DesignStatusMenuStyleResolver.chevron.color)
        }
        .padding(.vertical, DesignStatusMenuMetrics.verticalPadding)
        .padding(.horizontal, DesignStatusMenuMetrics.horizontalPadding)
        .background(
            RoundedRectangle(cornerRadius: DesignStatusMenuMetrics.cornerRadius, style: .continuous)
                .fill(DesignStatusMenuStyleResolver.background.color)
        )
    }
}
