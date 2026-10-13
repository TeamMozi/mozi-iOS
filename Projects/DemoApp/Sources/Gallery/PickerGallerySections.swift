import SharedDesignSystem
import SwiftUI

/// 입력 화면의 고르기 부품. 달력·시간 휠·목록 줄을 누르면 실제로 바뀐다.
struct CalendarGallerySection: View {
    private let today = DesignCalendarDay(year: 2026, month: 7, day: 16)
    @State private var month = DesignCalendarMonth(year: 2026, month: 7)
    @State private var selection: DesignCalendarDay? = DesignCalendarDay(year: 2026, month: 7, day: 25)

    var body: some View {
        GallerySection("달력 · 오늘 7월 16일 · 지난 날은 흐림") {
            DesignCalendar(
                month: month,
                selection: selection,
                today: today,
                minimumMonth: today.calendarMonth,
                isSelectable: { [today] day in day >= today },
                onSelect: { selection = $0 },
                onMonthChange: { month = $0 }
            )
        }
    }
}

struct TimeWheelGallerySection: View {
    @State private var time = DesignClockTime(hour: 20, minute: 0)

    var body: some View {
        GallerySection("시간 휠 · 5분 간격") {
            DesignTimeWheel(selection: time) { time = $0 }
        }
    }
}

struct ListRowGallerySection: View {
    @State private var selected = 1

    var body: some View {
        GallerySection("목록 줄 · 누르면 고른 줄") {
            VStack(spacing: 0) {
                ForEach(Array(ListRowGallerySample.places.enumerated()), id: \.offset) { index, place in
                    Button {
                        selected = index
                    } label: {
                        DesignListRow(place.name, subtitle: place.address, isSelected: selected == index) {
                            Image.ds.icon.location.filled
                                .iconSize(CGFloat.ds.iconSize._24)
                                .foregroundStyle(Color.ds.text.neutral.subtle)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        GallerySection("목록 줄 · 장소 모양(.place)") {
            VStack(spacing: 0) {
                ForEach(Array(ListRowGallerySample.places.enumerated()), id: \.offset) { index, place in
                    Button {
                        selected = index
                    } label: {
                        DesignListRow(
                            place.name,
                            subtitle: place.address,
                            isSelected: selected == index,
                            style: .place
                        ) {
                            EmptyView()
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        GallerySection("목록 줄 · 곡 모양(.music)") {
            VStack(spacing: 0) {
                ForEach(Array(ListRowGallerySample.songs.enumerated()), id: \.offset) { index, song in
                    Button {
                        selected = index
                    } label: {
                        DesignListRow(song.title, subtitle: song.detail, isSelected: selected == index, style: .music) {
                            RoundedRectangle(cornerRadius: CGFloat.ds.radius._4)
                                .fill(Color.ds.fill.neutral.strong)
                                .frame(width: 40, height: 40)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private enum ListRowGallerySample {
    static let songs: [(title: String, detail: String)] = [
        ("sending three hearts to a stranger at 2am (sped up)", "1:39 · 110회 사용"),
        ("mozibgm1:)))", "2:05 · 42회 사용"),
    ]

    static let places: [(name: String, address: String)] = [
        ("히든스테이", "서울 구로구 구로동로26길 62"),
        ("홍대파티룸 히든스테이", "서울 마포구 와우산로3길 48"),
        ("히든스테이", "강원특별자치도 양양군 양양읍 내곡길 16-16"),
    ]
}
