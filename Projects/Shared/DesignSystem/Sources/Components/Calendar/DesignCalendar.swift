import SwiftUI

/// 날짜 고르기 달력(시안 `2774:118148` › Calendar). 보여 줄 달·고른 날·오늘·고를 수 있는 날은 쓰는 쪽이 넘긴다.
/// 고를 수 없는 날과 그 달 밖의 날은 흐리게 그리고 누르지 못한다. 오늘은 테두리, 고른 날은 채운 원이다.
/// 높이는 주 수를 따른다(다섯 주 298). 너비는 쓰는 쪽 칸을 채운다.
public struct DesignCalendar: View {
    private let month: DesignCalendarMonth
    private let selection: DesignCalendarDay?
    private let today: DesignCalendarDay
    private let minimumMonth: DesignCalendarMonth?
    private let isSelectable: (DesignCalendarDay) -> Bool
    private let onSelect: @MainActor (DesignCalendarDay) -> Void
    private let onMonthChange: @MainActor (DesignCalendarMonth) -> Void

    /// - Parameter minimumMonth: 이 달보다 앞으로는 넘기지 못한다. 비우면 막지 않는다.
    public init(
        month: DesignCalendarMonth,
        selection: DesignCalendarDay?,
        today: DesignCalendarDay,
        minimumMonth: DesignCalendarMonth? = nil,
        isSelectable: @escaping (DesignCalendarDay) -> Bool,
        onSelect: @escaping @MainActor (DesignCalendarDay) -> Void,
        onMonthChange: @escaping @MainActor (DesignCalendarMonth) -> Void
    ) {
        self.month = month
        self.selection = selection
        self.today = today
        self.minimumMonth = minimumMonth
        self.isSelectable = isSelectable
        self.onSelect = onSelect
        self.onMonthChange = onMonthChange
    }

    public var body: some View {
        let cells = DesignCalendarGrid.cells(for: month)
        let weeks = stride(from: 0, to: cells.count, by: 7).map { Array(cells[$0..<min($0 + 7, cells.count)]) }
        VStack(spacing: DesignCalendarMetrics.sectionSpacing) {
            header
            VStack(spacing: 0) {
                weekdayRow
                ForEach(weeks, id: \.self) { week in
                    weekRow(week)
                }
            }
        }
        // 시안 달 칸은 주 칸 합보다 4 짧다(270 = 34 + 48 × 5 − 4). 마지막 주의 아래 여백 6 안에서 넘친다.
        .frame(height: DesignCalendarMetrics.height(weekCount: weeks.count), alignment: .top)
    }

    private var header: some View {
        HStack(spacing: DesignCalendarMetrics.headerSpacing) {
            monthButton(Image.ds.icon.chevron.left, label: "이전 달", offset: -1)
                .disabled(minimumMonth.map { month <= $0 } ?? false)
            DesignText(
                "\(month.year)년 \(month.month)월",
                style: DesignCalendarMetrics.headerStyle,
                color: DesignCalendarPalette.header.color
            )
            monthButton(Image.ds.icon.chevron.right, label: "다음 달", offset: 1)
        }
        .frame(height: DesignCalendarMetrics.headerHeight)
    }

    private var weekdayRow: some View {
        HStack(spacing: 0) {
            ForEach(DesignCalendarMetrics.weekdays, id: \.self) { weekday in
                DesignText(
                    weekday,
                    style: DesignCalendarMetrics.weekdayStyle,
                    color: DesignCalendarPalette.weekday.color,
                    alignment: .center
                )
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, DesignCalendarMetrics.weekdayHorizontalPadding)
        .frame(height: DesignCalendarMetrics.weekdayHeight)
    }

    /// 시안 주 칸은 44 날짜 칸 일곱을 양 끝에 붙이고 사이를 고르게 벌린다.
    private func weekRow(_ week: [DesignCalendarCell]) -> some View {
        HStack(spacing: 0) {
            ForEach(Array(week.enumerated()), id: \.element) { index, cell in
                if index > 0 {
                    Spacer(minLength: 0)
                }
                dayButton(cell)
            }
        }
    }

    private func monthButton(_ icon: Image, label: String, offset: Int) -> some View {
        Button {
            onMonthChange(month.adding(months: offset))
        } label: {
            icon
                .iconSize(DesignCalendarMetrics.arrowIconSize)
                .foregroundStyle(DesignCalendarPalette.arrow.color)
                .frame(width: DesignCalendarMetrics.arrowFrame, height: DesignCalendarMetrics.arrowFrame)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    private func dayButton(_ cell: DesignCalendarCell) -> some View {
        let isEnabled = cell.isInMonth && isSelectable(cell.day)
        let isSelected = cell.day == selection
        let isToday = cell.day == today
        return Button {
            onSelect(cell.day)
        } label: {
            DesignText(
                "\(cell.day.day)",
                style: isSelected ? DesignCalendarMetrics.selectedDayStyle : DesignCalendarMetrics.dayStyle,
                color: DesignCalendarPalette.dayText(isEnabled: isEnabled, isSelected: isSelected, isToday: isToday)
                    .color,
                alignment: .center
            )
            .frame(width: DesignCalendarMetrics.markSize, height: DesignCalendarMetrics.markSize)
            .background {
                if isSelected {
                    Circle().fill(DesignCalendarPalette.selectedFill.color)
                }
            }
            .overlay {
                if isToday, !isSelected {
                    Circle().strokeBorder(DesignCalendarPalette.todayRing.color, lineWidth: CGFloat.ds.border.thin)
                }
            }
            .frame(width: DesignCalendarMetrics.dayWidth, height: DesignCalendarMetrics.dayHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityLabel("\(cell.day.month)월 \(cell.day.day)일")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

/// 시안 Calendar 의 치수와 글자 모양. 토큰이 없는 값을 여기 둔다.
enum DesignCalendarMetrics {
    static let weekdays = ["일", "월", "화", "수", "목", "금", "토"]
    /// 년월 줄. 화살표 칸 24 · 년월 글자 · 화살표 칸 24 를 간격 8 로 가운데 둔다.
    static let headerHeight: CGFloat = 24
    static let headerSpacing: CGFloat = CGFloat.ds.spacing.sm
    static let arrowFrame: CGFloat = CGFloat.ds.iconSize._24
    /// 아이콘 `chevron` 은 24 틀에 글리프 높이 18 이다. 시안 글리프(7×13)에 맞춰 높이 13 이 되게 줄인다.
    static let arrowIconSize: CGFloat = 24 * 13 / 18
    /// 년월 줄과 요일 줄 사이.
    static let sectionSpacing: CGFloat = CGFloat.ds.spacing.xs
    static let weekdayHeight: CGFloat = 34
    static let weekdayHorizontalPadding: CGFloat = 1
    static let dayWidth: CGFloat = 44
    static let dayHeight: CGFloat = 48
    /// 오늘 테두리·고른 날 원. 날짜 칸 안 위아래 6·좌우 4.
    static let markSize: CGFloat = 36
    /// 시안 달 칸(요일 + 주)은 주 칸 합보다 4 짧다(다섯 주 270).
    private static let monthOverlap: CGFloat = 4

    static let headerStyle = TextStyle.ds.headline.semiBold
    /// 요일. Medium 14/20, 자간 −0.5px. 글자 스타일 토큰에 없다.
    static let weekdayStyle = TextStyle.ds.pretendard(.medium, size: 14, lineHeight: 20, letterSpacingEm: -0.5 / 14)
    static let dayStyle = TextStyle.ds.headline.medium
    static let selectedDayStyle = TextStyle.ds.headline.semiBold

    /// 달력 전체 높이. 년월 24 + 4 + 요일 34 + 48 × 주 − 4. 다섯 주는 298 이다.
    static func height(weekCount: Int) -> CGFloat {
        headerHeight + sectionSpacing + weekdayHeight + dayHeight * CGFloat(weekCount) - monthOverlap
    }
}

/// 시안 Calendar 의 색.
enum DesignCalendarPalette {
    static let header = SemanticColor.text.neutral.secondary
    static let weekday = SemanticColor.text.neutral.secondary
    /// 시안 화살표 글리프는 `border/neutral/50` 이다(다크 #7A7887 · 라이트 #484753).
    static let arrow = SemanticColor.border.neutral._50
    static let todayRing = SemanticColor.text.accent.default
    static let selectedFill = SemanticColor.text.accent.default

    static func dayText(isEnabled: Bool, isSelected: Bool, isToday: Bool) -> ThemedColor {
        if isSelected {
            return SemanticColor.text.neutral.inverse
        }
        if !isEnabled {
            return SemanticColor.text.neutral.faint
        }
        return isToday ? SemanticColor.text.accent.strong : SemanticColor.text.neutral.secondary
    }
}
