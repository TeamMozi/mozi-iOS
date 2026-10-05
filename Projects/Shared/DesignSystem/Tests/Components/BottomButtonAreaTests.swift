@testable import SharedDesignSystem
import SwiftUI
import UIKit
import XCTest

final class BottomButtonAreaTests: XCTestCase {
    func test_위_여백은_버튼_하나와_5대5는_12이고_3대7은_16이다() {
        XCTAssertEqual(BottomButtonArrangement.single.topPadding, 12)
        XCTAssertEqual(BottomButtonArrangement.split5To5.topPadding, 12)
        XCTAssertEqual(BottomButtonArrangement.split3To7.topPadding, 16)
    }

    func test_좌우_여백_16_간격_12_위쪽_선_1_오른쪽_고정_너비_240이다() {
        XCTAssertEqual(BottomButtonAreaMetrics.horizontalPadding, 16)
        XCTAssertEqual(BottomButtonAreaMetrics.spacing, 12)
        XCTAssertEqual(BottomButtonAreaMetrics.topBorderWidth, 1)
        XCTAssertEqual(BottomButtonAreaMetrics.trailingFixedWidth, 240)
    }

    func test_바탕과_위쪽_선은_Figma_의미_색이다() {
        XCTAssertEqual(BottomButtonAreaMetrics.background, SemanticColor.fill.neutral.default)
        XCTAssertEqual(BottomButtonAreaMetrics.topBorder, SemanticColor.border.neutral._10)
    }

    func test_버튼_하나는_가로를_채운다() {
        XCTAssertEqual(BottomButtonArrangement.single.widths(in: 343, count: 1), [343])
    }

    func test_5대5는_간격_12를_빼고_같은_너비로_나눈다() {
        XCTAssertEqual(BottomButtonArrangement.split5To5.widths(in: 343, count: 2), [165.5, 165.5])
    }

    func test_3대7은_오른쪽이_240이고_왼쪽이_나머지를_채운다() {
        XCTAssertEqual(BottomButtonArrangement.split3To7.widths(in: 343, count: 2), [91, 240])
    }

    func test_3대7에서_너비가_모자라면_왼쪽이_0이_되고_오른쪽이_남은_너비를_받는다() {
        XCTAssertEqual(BottomButtonArrangement.split3To7.widths(in: 200, count: 2), [0, 188])
    }

    func test_버튼이_없으면_너비를_나누지_않는다() {
        XCTAssertEqual(BottomButtonArrangement.single.widths(in: 343, count: 0), [])
        XCTAssertEqual(BottomButtonArrangement.split3To7.widths(in: 343, count: 0), [])
    }

    func test_키보드가_없으면_본문_아래_여백은_영역_높이다() {
        XCTAssertEqual(BottomButtonAreaInset.content(areaHeight: 60, fullHeight: 709, keyboardAvoidingHeight: 709), 60)
    }

    func test_키보드가_영역보다_높이_가리면_본문_아래_여백은_키보드가_가린_높이다() {
        XCTAssertEqual(BottomButtonAreaInset.content(areaHeight: 60, fullHeight: 709, keyboardAvoidingHeight: 408), 301)
    }

    func test_키보드가_영역보다_낮게_가리면_본문_아래_여백은_영역_높이다() {
        XCTAssertEqual(BottomButtonAreaInset.content(areaHeight: 60, fullHeight: 709, keyboardAvoidingHeight: 689), 60)
    }

    @MainActor
    func test_버튼_하나_영역_높이는_위_여백_12와_버튼_48의_합이다() {
        let area = BottomButtonArea(.single) {
            Color.red.frame(height: 48)
        }
        XCTAssertEqual(fittingSize(area, width: 375).height, 60, accuracy: 0.5)
    }

    @MainActor
    func test_3대7_영역_높이는_위_여백_16과_버튼_48의_합이다() {
        let area = BottomButtonArea(.split3To7) {
            Color.red.frame(height: 48)
            Color.blue.frame(height: 48)
        }
        XCTAssertEqual(fittingSize(area, width: 375).height, 64, accuracy: 0.5)
    }

    @MainActor
    func test_윗줄이_있으면_위_여백_12_윗줄_간격_12_버튼_48을_쌓는다() {
        let area = BottomButtonArea(.single, showsTopBorder: true) {
            Color.blue.frame(height: 20)
        } buttons: {
            Color.red.frame(height: 48)
        }
        XCTAssertEqual(fittingSize(area, width: 375).height, 92, accuracy: 0.5)
    }

    // 창에 붙이지 않은 호스트라 안전 영역이 0 이다. 아래 여백(안전 영역)은 높이에 들어가지 않는다.
    @MainActor
    private func fittingSize(_ view: some View, width: CGFloat) -> CGSize {
        let host = UIHostingController(rootView: view)
        return host.sizeThatFits(in: CGSize(width: width, height: .greatestFiniteMagnitude))
    }
}
