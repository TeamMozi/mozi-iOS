@testable import MoziDemoKit
import SharedDesignSystem
import SwiftUI
import XCTest

final class FramePartsCatalogTests: XCTestCase {
    func test_하단_버튼_영역_견본은_Figma_변형_다섯을_Figma_순서로_보인다() {
        XCTAssertEqual(BottomButtonAreaSample.allCases.map(\.title), [
            "Single_Basic",
            "Split 5:5",
            "Split 3:7",
            "Single_Caption",
            "Single_Link",
        ])
    }

    func test_하단_버튼_영역_견본의_배치는_하나_5대5_3대7_하나_하나다() {
        XCTAssertEqual(
            BottomButtonAreaSample.allCases.map(\.arrangement),
            [.single, .split5To5, .split3To7, .single, .single]
        )
    }

    func test_윗줄이_있는_두_견본만_위쪽_선을_켠다() {
        XCTAssertEqual(
            BottomButtonAreaSample.allCases.map(\.showsTopBorder),
            [false, false, false, true, true]
        )
    }

    func test_전체_화면_견본은_헤더_탭바_바텀시트_순서다() {
        XCTAssertEqual(FrameSample.allCases.map(\.title), ["헤더", "탭바", "바텀시트"])
    }

    func test_헤더_견본은_투명_채움_글자_버튼_오른쪽_버튼_둘_왼쪽_정렬_제목_순서다() {
        XCTAssertEqual(
            HeaderSample.allCases.map(\.title),
            ["투명", "채움", "글자 버튼", "오른쪽 버튼 둘", "왼쪽 정렬 제목"]
        )
    }

    func test_헤더_견본은_채움만_채움_배경이고_나머지는_투명_배경이다() {
        XCTAssertEqual(
            HeaderSample.allCases.map(\.background),
            [.transparent, .filled, .transparent, .transparent, .transparent]
        )
    }

    func test_바텀시트_견본은_기본과_왼쪽_정렬_제목을_large와_medium으로_연다() {
        XCTAssertEqual(BottomSheetSample.allCases.map(\.title), [
            "기본 · large",
            "기본 · medium",
            "왼쪽 정렬 제목 · large",
            "왼쪽 정렬 제목 · medium",
        ])
        XCTAssertEqual(BottomSheetSample.allCases.map(\.detent), [.large, .medium, .large, .medium])
        XCTAssertEqual(BottomSheetSample.allCases.map(\.isLeadingTitle), [false, false, true, true])
    }
}
