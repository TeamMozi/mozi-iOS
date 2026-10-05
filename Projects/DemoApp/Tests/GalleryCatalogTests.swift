@testable import MoziDemoKit
import SwiftUI
import XCTest

final class GalleryCatalogTests: XCTestCase {
    func test_색_묶음은_Figma_의미_색_묶음_17개를_Figma_순서로_보인다() {
        XCTAssertEqual(GalleryCatalog.colorGroups.map(\.title), [
            "text/neutral",
            "text/accent",
            "fill/neutral",
            "fill/accent",
            "border/neutral",
            "border/accent",
            "button/background/main",
            "button/background/neutral",
            "button/background/ghost",
            "button/background/icon",
            "button/label/main",
            "button/label/neutral",
            "button/label/ghost",
            "button/label/text",
            "overlay/dim",
            "overlay/inverse",
            "overlay/gray",
        ])
    }

    func test_색_묶음마다_Figma_의미_색_개수만큼_칸을_보인다() {
        XCTAssertEqual(
            GalleryCatalog.colorGroups.map(\.swatches.count),
            [6, 4, 8, 3, 7, 3, 3, 3, 3, 1, 3, 3, 3, 2, 6, 3, 2]
        )
    }

    func test_색_칸_63개의_이름이_서로_다르고_자기_묶음_경로로_시작한다() {
        let names = GalleryCatalog.colorGroups.flatMap { $0.swatches.map(\.name) }
        XCTAssertEqual(Set(names).count, 63)

        for group in GalleryCatalog.colorGroups {
            let prefix = group.title.replacingOccurrences(of: "/", with: ".") + "."
            for swatch in group.swatches {
                XCTAssertTrue(swatch.name.hasPrefix(prefix), "\(swatch.name) 이 \(group.title) 묶음에 있다")
            }
        }
    }

    func test_색_칸_아래_이름은_묶음_이름을_빼고_마지막_낱말만_보인다() {
        XCTAssertEqual(shortName(of: "text.neutral.primary"), "primary")
        XCTAssertEqual(shortName(of: "border.neutral._10"), "10")
        XCTAssertEqual(shortName(of: "button.background.main.default"), "default")
        XCTAssertEqual(shortName(of: "overlay.dim._60"), "60")
    }

    func test_색_칸_63개의_짧은_이름은_비어_있지_않고_점이나_밑줄로_시작하지_않는다() {
        let swatches = GalleryCatalog.colorGroups.flatMap(\.swatches)
        XCTAssertEqual(swatches.count, 63)

        for swatch in swatches {
            XCTAssertFalse(swatch.shortName.isEmpty, "\(swatch.name) 의 짧은 이름이 비었다")
            XCTAssertFalse(swatch.shortName.hasPrefix("."), "\(swatch.name) 의 짧은 이름이 점으로 시작한다")
            XCTAssertFalse(swatch.shortName.hasPrefix("_"), "\(swatch.name) 의 짧은 이름이 밑줄로 시작한다")
        }
    }

    func test_글자_견본은_스타일_21개를_Figma_순서로_보인다() {
        XCTAssertEqual(GalleryCatalog.textSamples.map(\.name), [
            "title1.bold",
            "title2.regular",
            "title2.semiBold",
            "title2.bold",
            "title3.regular",
            "title3.semiBold",
            "headline.regular",
            "headline.medium",
            "headline.semiBold",
            "body.regular",
            "body.medium",
            "body.semiBold",
            "subtext.regular",
            "subtext.medium",
            "caption1.regular",
            "caption1.medium",
            "caption1.semiBold",
            "caption1.bold",
            "caption2.regular",
            "caption2.medium",
            "caption2.semiBold",
        ])
    }

    func test_글자_묶음은_Figma_묶음_8개를_Figma_순서로_보인다() {
        XCTAssertEqual(GalleryCatalog.textGroups.map(\.title), [
            "Title1",
            "Title2",
            "Title3",
            "Headline",
            "Body",
            "Subtext",
            "Caption1",
            "Caption2",
        ])
    }

    func test_글자_묶음마다_스타일_개수만큼_견본을_보이고_합은_21개다() {
        let counts = GalleryCatalog.textGroups.map(\.samples.count)
        XCTAssertEqual(counts, [1, 3, 2, 3, 3, 2, 4, 3])
        XCTAssertEqual(counts.reduce(0, +), 21)
    }

    func test_글자_묶음을_이어_붙이면_스타일_21개의_Figma_순서와_같다() {
        XCTAssertEqual(
            GalleryCatalog.textGroups.flatMap(\.samples).map(\.name),
            GalleryCatalog.textSamples.map(\.name)
        )
    }

    func test_글자_견본_이름은_묶음_이름을_빼고_굵기만_보인다() {
        XCTAssertEqual(textShortName(of: "title2.semiBold"), "semiBold")
        XCTAssertEqual(textShortName(of: "caption1.bold"), "bold")
        XCTAssertEqual(textShortName(of: "title1.bold"), "bold")
    }

    func test_글자_수치_줄은_크기_줄높이_자간_굵기를_스타일_값에서_만든다() {
        XCTAssertEqual(metricsLabel(of: "body.semiBold"), "16 · 줄 24 · 자간 -1% (-0.16pt) · SemiBold")
        XCTAssertEqual(metricsLabel(of: "title1.bold"), "28 · 줄 34 · 자간 -2% (-0.56pt) · Bold")
        XCTAssertEqual(metricsLabel(of: "headline.medium"), "16 · 줄 22 · 자간 -2% (-0.32pt) · Medium")
        XCTAssertEqual(metricsLabel(of: "caption2.regular"), "12 · 줄 14 · 자간 -1% (-0.12pt) · Regular")
    }

    func test_디자인_시스템_칸은_색_글자_버튼_화면_상태_네_화면을_이_순서로_연다() {
        XCTAssertEqual(GalleryScreen.allCases.map(\.title), ["색", "글자", "버튼", "화면 상태"])
    }

    func test_화면_상태_화면은_대기_불러오는_중_동작_실패_불러오기_실패를_이_순서로_고른다() {
        XCTAssertEqual(
            GalleryScreenStatusSample.allCases.map(\.title),
            ["대기", "불러오는 중", "동작 실패", "불러오기 실패"]
        )
    }

    func test_화면_상태_견본은_고른_칸에_맞는_상태를_띄운다() {
        XCTAssertEqual(
            GalleryScreenStatusSample.allCases.map(\.status),
            [
                .idle,
                .loading,
                .actionFailed(message: "저장하지 못했어요"),
                .loadFailed(message: "내용을 불러오지 못했어요"),
            ]
        )
    }

    func test_모드_전환의_시스템은_기기_모드를_덮어쓰지_않는다() {
        XCTAssertNil(GalleryAppearance.system.colorScheme)
        XCTAssertEqual(GalleryAppearance.dark.colorScheme, .dark)
        XCTAssertEqual(GalleryAppearance.light.colorScheme, .light)
    }

    private func shortName(of name: String) -> String? {
        GalleryCatalog.colorGroups.flatMap(\.swatches).first { $0.name == name }?.shortName
    }

    private func textShortName(of name: String) -> String? {
        GalleryCatalog.textGroups.flatMap(\.samples).first { $0.name == name }?.shortName
    }

    private func metricsLabel(of name: String) -> String? {
        GalleryCatalog.textSamples.first { $0.name == name }?.metricsLabel
    }
}
