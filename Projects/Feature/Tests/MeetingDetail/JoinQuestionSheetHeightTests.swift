import Domain
@testable import Feature
import SwiftUI
import ThirdParty
import UIKit
import XCTest

/// 가입 질문 시트 높이는 내용에 맞춘다. 질문이 늘면 높이도 는다.
@MainActor
final class JoinQuestionSheetHeightTests: XCTestCase {
    func test_재지_않은_부분이_있으면_높이를_올리지_않는다() {
        XCTAssertEqual(JoinQuestionSheetLayout.fittingHeight(header: 0, questions: 98, bottomArea: 60), 0)
        XCTAssertEqual(JoinQuestionSheetLayout.fittingHeight(header: 54, questions: 0, bottomArea: 60), 0)
        XCTAssertEqual(JoinQuestionSheetLayout.fittingHeight(header: 54, questions: 98, bottomArea: 0), 0)
    }

    func test_헤더_질문_하단_영역_높이의_합을_올림한다() {
        XCTAssertEqual(JoinQuestionSheetLayout.fittingHeight(header: 54, questions: 98.33, bottomArea: 60), 213)
    }

    func test_질문이_셋이면_하나일_때보다_질문_사이_간격_둘보다_더_높다() async throws {
        let one = try await fittingHeight(questionCount: 1)
        let three = try await fittingHeight(questionCount: 3)
        XCTAssertGreaterThan(one, 0)
        XCTAssertGreaterThan(three, one + 2 * JoinQuestionSheetLayout.questionSpacing)
    }

    private func fittingHeight(questionCount: Int) async throws -> CGFloat {
        var meeting = try await MeetingClient.previewValue.meeting(id: MeetingClient.PreviewID.none)
        meeting.joinQuestions = Array(repeating: "제일 좋아하는 밴드 적어주세요!!", count: questionCount)
        var state = MeetingDetailFeature.State(meetingID: meeting.id)
        state.meeting = meeting
        state.joinAnswers = Array(repeating: "", count: questionCount)
        let store = Store(initialState: state) { MeetingDetailFeature() }
        var measured: CGFloat = 0
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        window.rootViewController = UIHostingController(
            rootView: JoinQuestionSheet(store: store) { measured = $0 }.dynamicTypeSize(.large)
        )
        window.makeKeyAndVisible()
        for _ in 0..<10 {
            try await Task.sleep(nanoseconds: 100_000_000)
        }
        window.isHidden = true
        window.rootViewController = nil
        return measured
    }
}
