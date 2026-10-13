import SharedDesignSystem
import SwiftUI

/// 「모임 소개」·「상세 정보」. 글이 없으면 구간을 그리지 않는다.
struct MeetingDetailTextSection: View {
    let title: String
    let text: String?

    var body: some View {
        if let text, !text.isEmpty {
            VStack(alignment: .leading, spacing: CGFloat.ds.spacing.sm) {
                MeetingDetailSectionTitle(title: title)
                paragraphs(text)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, CGFloat.ds.layout.margin)
        }
    }

    /// 시안 글 스타일의 문단 간격 4 를 줄바꿈마다 띄워 쌓는다. `TextStyle` 에 문단 간격 칸이 없다.
    /// 빈 줄도 한 문단이라 한 줄 높이를 차지한다.
    private func paragraphs(_ text: String) -> some View {
        let lines = Self.lines(of: text)
        return VStack(alignment: .leading, spacing: CGFloat.ds.spacing.xs) {
            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                DesignText(
                    line.isEmpty ? " " : line,
                    style: TextStyle.ds.body.regular,
                    color: Color.ds.text.neutral.secondary
                )
            }
        }
        .accessibilityElement(children: .combine)
    }

    /// `\r\n` 을 먼저 `\n` 으로 바꾼다. 그대로 나누면 줄 끝에 `\r` 이 남는다.
    static func lines(of text: String) -> [String] {
        text.replacingOccurrences(of: "\r\n", with: "\n").components(separatedBy: "\n")
    }
}
