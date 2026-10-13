import SharedDesignSystem
import SwiftUI

/// 멤버 한 줄. 시안 `Member`(`2774:116622`) — 프로필 원 + 닉네임, 오른쪽에 쓰는 탭이 정한 버튼
struct MemberRow<Trailing: View>: View {
    let nickname: String
    let imageURL: URL?
    @ViewBuilder let trailing: () -> Trailing

    var body: some View {
        HStack(spacing: MemberRowLayout.avatarToNicknameSpacing) {
            DesignAvatar(imageURL, diameter: MemberRowLayout.avatarDiameter)
            DesignText(nickname, style: TextStyle.ds.caption1.regular, lineLimit: 1)
            Spacer(minLength: 0)
            trailing()
        }
        .padding(.vertical, MemberRowLayout.verticalPadding)
        .padding(.horizontal, MemberRowLayout.horizontalPadding)
    }
}

/// 빈 탭 안내. 시안이 없는 임시 문구 자리다
struct MemberEmptyRow: View {
    private let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        DesignText(text, style: TextStyle.ds.body.regular, color: Color.ds.text.neutral.subtle)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, MemberRowLayout.verticalPadding)
            .padding(.horizontal, MemberRowLayout.horizontalPadding)
    }
}

private enum MemberRowLayout {
    static let avatarDiameter: CGFloat = 28
    static let avatarToNicknameSpacing: CGFloat = CGFloat.ds.spacing.sm
    static let verticalPadding: CGFloat = CGFloat.ds.spacing.sm
    static let horizontalPadding: CGFloat = 10
}
