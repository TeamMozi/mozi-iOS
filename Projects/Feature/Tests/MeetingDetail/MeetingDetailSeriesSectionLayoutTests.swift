import Domain
@testable import Feature
import SwiftUI
import UIKit
import XCTest

/// 회차 카드 포스터가 어떤 비율이어도 시리즈 구간이 화면 폭을 넘지 않고,
/// 회차 수와 상관없이 포스터 칸이 시안 크기(390 폭에서 114×152, 3:4)다.
/// AsyncImage 는 테스트에서 언제 그려질지 알 수 없어 포스터 자리에 그림을 바로 넣는다.
@MainActor
final class MeetingDetailSeriesSectionLayoutTests: XCTestCase {
    private static let screenWidth: CGFloat = 390
    /// 화면의 다른 색과 겹치지 않는 순수한 빨강
    private static let posterColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
    /// 시안 회차 포스터 칸
    private static let posterBox = CGSize(width: 114, height: 152)

    func test_회차_포스터가_정사각형이어도_화면_폭을_넘지_않는다() async throws {
        try await assertFitsScreen(posterSize: CGSize(width: 40, height: 40), name: "square")
    }

    func test_회차_포스터가_가로로_길어도_화면_폭을_넘지_않는다() async throws {
        try await assertFitsScreen(posterSize: CGSize(width: 160, height: 40), name: "wide")
    }

    func test_회차가_셋이면_포스터_칸이_시안_크기다() async throws {
        try await assertPosterBoxes(episodeCount: 3)
    }

    /// 데모 시리즈는 회차가 둘이다. 카드가 줄을 반씩 나눠 가로로 길어지면 안 된다.
    func test_회차가_둘이어도_포스터_칸이_시안_크기다() async throws {
        try await assertPosterBoxes(episodeCount: 2)
    }

    func test_회차가_하나여도_포스터_칸이_시안_크기다() async throws {
        try await assertPosterBoxes(episodeCount: 1)
    }

    private func assertPosterBoxes(episodeCount: Int) async throws {
        let section = try await Self.section(episodeCount: episodeCount, posterSize: CGSize(width: 40, height: 40))
        let boxes = try Self.posterBoxes(in: Self.render(section))
        XCTAssertEqual(boxes.count, episodeCount, "포스터 칸 수")
        for box in boxes {
            XCTAssertEqual(box.width, Self.posterBox.width, accuracy: 1, "회차 \(episodeCount)개일 때 포스터 폭")
            XCTAssertEqual(box.height, Self.posterBox.height, accuracy: 1, "회차 \(episodeCount)개일 때 포스터 높이")
        }
    }

    private func assertFitsScreen(posterSize: CGSize, name: String) async throws {
        let section = try await Self.section(episodeCount: 3, posterSize: posterSize)

        let rendered = try Self.render(section)
        XCTAssertFalse(Self.posterBoxes(in: rendered).isEmpty, "포스터 \(name) 가 그려지지 않았다")

        let content = UIHostingController(rootView: section)
        let size = content.sizeThatFits(in: CGSize(width: Self.screenWidth, height: .greatestFiniteMagnitude))
        XCTAssertLessThanOrEqual(size.width, Self.screenWidth + 0.5, "포스터 \(name) 에서 구간 폭이 \(size.width)")
    }

    private static func poster(size: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            posterColor.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }

    private static func section(episodeCount: Int, posterSize: CGSize) async throws -> MeetingDetailSeriesSection {
        let meeting = try await MeetingDetailFixtures.meeting(MyParticipation.none, seriesID: "series-1")
        let episodes = (1...episodeCount).map { number -> Meeting in
            var episode = meeting
            episode.id = "episode-\(number)"
            return episode
        }
        return MeetingDetailSeriesSection(
            series: MeetingDetailFixtures.series(),
            episodes: episodes,
            fixedPoster: Image(uiImage: poster(size: posterSize))
        )
    }

    private static func render(_ section: MeetingDetailSeriesSection) throws -> CGImage {
        let renderer = ImageRenderer(content: section.frame(width: screenWidth))
        renderer.scale = 1
        return try XCTUnwrap(renderer.cgImage)
    }

    /// 포스터 빨강이 칠해진 칸들. 날짜 띠가 덮은 어두운 빨강도 포스터로 센다.
    /// 날짜 띠는 흐린 포스터 위 검정 60% 라 빨강이 약 40% 밝기(빨강 102)로 남는다. 빨강 기준을 80 으로 낮춰 둔 까닭이다.
    /// 왼쪽부터 빨강이 이어지는 열 묶음마다 폭과 위아래 끝을 잰다.
    private static func posterBoxes(in image: CGImage) -> [CGRect] {
        let width = image.width
        let height = image.height
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        let drawn = pixels.withUnsafeMutableBytes { buffer -> Bool in
            guard let context = CGContext(
                data: buffer.baseAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else { return false }
            context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }
        XCTAssertTrue(drawn, "화소를 읽지 못했다")
        func isPoster(_ x: Int, _ y: Int) -> Bool {
            let offset = (y * width + x) * 4
            return pixels[offset] > 80 && pixels[offset + 1] < 15 && pixels[offset + 2] < 15 && pixels[offset + 3] > 120
        }
        var boxes: [CGRect] = []
        var x = 0
        while x < width {
            guard (0..<height).contains(where: { isPoster(x, $0) }) else {
                x += 1
                continue
            }
            let startX = x
            var minY = height
            var maxY = -1
            while x < width {
                let rows = (0..<height).filter { isPoster(x, $0) }
                guard let first = rows.first, let last = rows.last else { break }
                minY = min(minY, first)
                maxY = max(maxY, last)
                x += 1
            }
            boxes.append(CGRect(x: startX, y: minY, width: x - startX, height: maxY - minY + 1))
        }
        return boxes
    }
}
