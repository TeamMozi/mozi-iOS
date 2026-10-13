/// 시안에 없는 확인 창 문구(임시). 모임 관리와 위젯이 같은 종료 확인 창을 쓴다.
enum MeetingConfirmationCopy {
    static let endTitle = "모임을 종료할까요?"
    static let endMessage = "종료한 모임은 다시 열 수 없어요."
    static let endButton = "종료"
    static let deleteTitle = "모임을 삭제할까요?"
    static let deleteMessage = "삭제한 모임은 되돌릴 수 없어요."
    static let deleteButton = "삭제"
    static let cancelButton = "취소"
    static let kickButton = "내보내기"

    static func kickTitle(_ nickname: String) -> String {
        "\(nickname)님을 내보낼까요?"
    }
}
