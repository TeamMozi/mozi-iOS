@testable import SharedDesignSystem
import SwiftUI
import UIKit
import XCTest

final class ImageAccessTests: XCTestCase {
    func test_Image_ds_경로가_아이콘_168개와_기존_이미지_7개() {
        let paths = leafPaths(of: Image.ds)

        XCTAssertEqual(paths.count, 175)
        XCTAssertEqual(paths.filter { $0.hasPrefix("icon.") }.count, 168)
        XCTAssertEqual(Set(paths), Set(ImageAccessPaths.all))
    }

    func test_기존_이미지_7장이_번들에서_불러와진다() {
        let names = [
            "logo_mozi",
            "login_shortform_01",
            "login_shortform_02",
            "login_shortform_03",
            "login_shortform_04",
            "icon_social_apple",
            "icon_social_kakao",
        ]

        for name in names {
            XCTAssertNotNil(
                UIImage(named: name, in: SharedDesignSystemResources.bundle, compatibleWith: nil),
                "Missing image asset: \(name)"
            )
        }
    }

    @MainActor
    func test_iconSize와_foregroundStyle로_크기와_색을_바꿔_그린다() throws {
        let view = Image.ds.icon.search.filled
            .iconSize(24)
            .foregroundStyle(Color(red: 1, green: 0, blue: 0))
        let renderer = ImageRenderer(content: view)
        renderer.scale = 1

        let cgImage = try XCTUnwrap(renderer.cgImage)
        XCTAssertEqual(cgImage.width, 24)
        XCTAssertEqual(cgImage.height, 24)

        let painted = try rgbaPixels(of: cgImage).filter { $0.alpha > 200 }
        XCTAssertFalse(painted.isEmpty)
        XCTAssertTrue(painted.allSatisfy { $0.red > 200 && $0.green < 60 && $0.blue < 60 })
    }

    private func leafPaths(of value: Any, prefix: String = "") -> [String] {
        if value is Image {
            return [prefix]
        }
        return Mirror(reflecting: value).children.flatMap { child -> [String] in
            guard let label = child.label else { return [] }
            let path = prefix.isEmpty ? label : "\(prefix).\(label)"
            return leafPaths(of: child.value, prefix: path)
        }
    }

    private func rgbaPixels(of image: CGImage) throws -> [RGBA] {
        let width = image.width
        let height = image.height
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        let drawn = bytes.withUnsafeMutableBytes { buffer -> Bool in
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
        XCTAssertTrue(drawn)
        return stride(from: 0, to: bytes.count, by: 4).map { index in
            RGBA(red: bytes[index], green: bytes[index + 1], blue: bytes[index + 2], alpha: bytes[index + 3])
        }
    }
}

private struct RGBA {
    let red: UInt8
    let green: UInt8
    let blue: UInt8
    let alpha: UInt8
}

private enum ImageAccessPaths {
    static let all: [String] = [
        "brand.logo",
        "icon.arrows.down",
        "icon.arrows.left",
        "icon.arrows.leftDown",
        "icon.arrows.leftUp",
        "icon.arrows.right",
        "icon.arrows.rightDown",
        "icon.arrows.rightUp",
        "icon.arrows.up",
        "icon.backspace.filled",
        "icon.backspace.outlined",
        "icon.bell.filled",
        "icon.bell.outlined",
        "icon.bellOff.filled",
        "icon.bellOff.outlined",
        "icon.bookmark.filled",
        "icon.bookmark.outlined",
        "icon.calendar.filled",
        "icon.calendar.outlined",
        "icon.camera.filled",
        "icon.camera.outlined",
        "icon.chat.filled",
        "icon.chat.outlined",
        "icon.check.filled",
        "icon.check.outlined",
        "icon.chevron.down",
        "icon.chevron.left",
        "icon.chevron.right",
        "icon.chevron.up",
        "icon.chevronUpDown.filled",
        "icon.chevronUpDown.outlined",
        "icon.chevronWide.down",
        "icon.chevronWide.left",
        "icon.chevronWide.right",
        "icon.chevronWide.up",
        "icon.close.filled",
        "icon.close.outlined",
        "icon.crop.filled",
        "icon.crop.outlined",
        "icon.cup.filled",
        "icon.cup.outlined",
        "icon.delete.filled",
        "icon.delete.outlined",
        "icon.download.filled",
        "icon.download.outlined",
        "icon.envelope.filled",
        "icon.envelope.outlined",
        "icon.eyedropper.filled",
        "icon.eyedropper.outlined",
        "icon.filter.filled",
        "icon.filter.outlined",
        "icon.flash.filled",
        "icon.flash.outlined",
        "icon.folder.filled",
        "icon.folder.outlined",
        "icon.folderMinus.filled",
        "icon.folderMinus.outlined",
        "icon.folderPlus.filled",
        "icon.folderPlus.outlined",
        "icon.folderShared.filled",
        "icon.folderShared.outlined",
        "icon.frame.filled",
        "icon.frame.outlined",
        "icon.gender.filled",
        "icon.gender.outlined",
        "icon.grid.bottomWide.filled",
        "icon.grid.bottomWide.outlined",
        "icon.grid.mosaic.filled",
        "icon.grid.mosaic.outlined",
        "icon.grid.oneByTwo.filled",
        "icon.grid.oneByTwo.outlined",
        "icon.grid.split.filled",
        "icon.grid.split.outlined",
        "icon.grid.topWide.filled",
        "icon.grid.topWide.outlined",
        "icon.grid.twoByTwo.filled",
        "icon.grid.twoByTwo.outlined",
        "icon.hashtag.filled",
        "icon.hashtag.outlined",
        "icon.heart.filled",
        "icon.heart.outlined",
        "icon.home.filled",
        "icon.home.outlined",
        "icon.idCard.filled",
        "icon.idCard.outlined",
        "icon.image.filled",
        "icon.image.outlined",
        "icon.info.filled",
        "icon.info.outlined",
        "icon.layers.filled",
        "icon.layers.outlined",
        "icon.link.filled",
        "icon.link.outlined",
        "icon.location.filled",
        "icon.location.outlined",
        "icon.locationArrow.filled",
        "icon.locationArrow.outlined",
        "icon.megaphone.filled",
        "icon.megaphone.outlined",
        "icon.menu.filled",
        "icon.menu.outlined",
        "icon.mic.filled",
        "icon.mic.outlined",
        "icon.micOff.filled",
        "icon.micOff.outlined",
        "icon.moreHorizontal.filled",
        "icon.moreHorizontal.outlined",
        "icon.moreVertical.filled",
        "icon.moreVertical.outlined",
        "icon.music.filled",
        "icon.music.outlined",
        "icon.note.filled",
        "icon.note.outlined",
        "icon.overlay.filled",
        "icon.overlay.outlined",
        "icon.paint.filled",
        "icon.paint.outlined",
        "icon.people.filled",
        "icon.people.outlined",
        "icon.person.filled",
        "icon.person.outlined",
        "icon.pin.filled",
        "icon.pin.outlined",
        "icon.playBox.filled",
        "icon.playBox.outlined",
        "icon.playCircle.filled",
        "icon.playCircle.outlined",
        "icon.playStack.filled",
        "icon.playStack.outlined",
        "icon.plus.filled",
        "icon.plus.outlined",
        "icon.poll.filled",
        "icon.poll.outlined",
        "icon.popcorn.filled",
        "icon.popcorn.outlined",
        "icon.question.filled",
        "icon.question.outlined",
        "icon.questionAlt.filled",
        "icon.questionAlt.outlined",
        "icon.refresh.filled",
        "icon.refresh.outlined",
        "icon.scale.filled",
        "icon.scale.outlined",
        "icon.search.filled",
        "icon.search.outlined",
        "icon.send.filled",
        "icon.send.outlined",
        "icon.setting.filled",
        "icon.setting.outlined",
        "icon.telegram.filled",
        "icon.telegram.outlined",
        "icon.text.filled",
        "icon.text.outlined",
        "icon.timer.filled",
        "icon.timer.outlined",
        "icon.trash.filled",
        "icon.trash.outlined",
        "icon.video.filled",
        "icon.video.outlined",
        "icon.volume.filled",
        "icon.volume.outlined",
        "icon.volumeOff.filled",
        "icon.volumeOff.outlined",
        "icon.xCircle.filled",
        "icon.xCircle.outlined",
        "icon.zoomIn.filled",
        "icon.zoomIn.outlined",
        "icon.zoomOut.filled",
        "icon.zoomOut.outlined",
        "login.shortform01",
        "login.shortform02",
        "login.shortform03",
        "login.shortform04",
        "social.apple",
        "social.kakao",
    ]
}
