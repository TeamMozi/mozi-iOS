@testable import SharedDesignSystem
import SwiftUI
import UIKit
import XCTest

final class ImageAccessTests: XCTestCase {
    func test_Image_ds_경로가_아이콘_168개와_기존_이미지_7개와_온보딩_그림_13개() {
        let paths = leafPaths(of: Image.ds)

        XCTAssertEqual(paths.count, 188)
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

    func test_온보딩_그림_13장은_번들에서_원래_색으로_불러와진다() {
        let names = [
            "onboarding_profile_default",
            "interest_hobby", "interest_growth", "interest_art", "interest_activity",
            "interest_friend", "interest_travel", "interest_food", "interest_pet",
            "interest_dessert", "interest_study", "interest_party", "interest_etc",
        ]

        for name in names {
            let image = UIImage(named: name, in: SharedDesignSystemResources.bundle, compatibleWith: nil)
            XCTAssertNotNil(image, "Missing image asset: \(name)")
            XCTAssertNotEqual(image?.renderingMode, .alwaysTemplate, "Template: \(name)")
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

    @MainActor
    func test_Image_ds_경로가_같은_이름의_에셋을_그린다() throws {
        XCTAssertEqual(ImageAccessAssets.all.count, 188)

        for entry in ImageAccessAssets.all {
            let viaPath = try rgbaPixels(of: render(entry.image))
            let viaName = try rgbaPixels(
                of: render(Image(decorative: entry.asset, bundle: SharedDesignSystemResources.bundle))
            )
            XCTAssertTrue(viaPath == viaName, "\(entry.asset) 경로가 다른 에셋을 그린다")
        }
    }

    @MainActor
    func test_다른_에셋은_다르게_그려진다() throws {
        let filled = try rgbaPixels(of: render(Image.ds.icon.search.filled))
        let outlined = try rgbaPixels(of: render(Image.ds.icon.search.outlined))

        XCTAssertFalse(filled == outlined)
    }

    @MainActor
    private func render(_ image: Image) throws -> CGImage {
        let renderer = ImageRenderer(content: image.iconSize(24).foregroundStyle(Color.black))
        renderer.scale = 1
        return try XCTUnwrap(renderer.cgImage)
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

private struct RGBA: Equatable {
    let red: UInt8
    let green: UInt8
    let blue: UInt8
    let alpha: UInt8
}

private enum ImageAccessPaths {
    static let all: [String] = [
        "brand.logo",
        "interest.activity",
        "interest.art",
        "interest.dessert",
        "interest.etc",
        "interest.food",
        "interest.friend",
        "interest.growth",
        "interest.hobby",
        "interest.party",
        "interest.pet",
        "interest.study",
        "interest.travel",
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
        "onboarding.profileDefault",
        "social.apple",
        "social.kakao",
    ]
}

private enum ImageAccessAssets {
    static let all: [(image: Image, asset: String)] = [
        (Image.ds.brand.logo, "logo_mozi"),
        (Image.ds.interest.activity, "interest_activity"),
        (Image.ds.interest.art, "interest_art"),
        (Image.ds.interest.dessert, "interest_dessert"),
        (Image.ds.interest.etc, "interest_etc"),
        (Image.ds.interest.food, "interest_food"),
        (Image.ds.interest.friend, "interest_friend"),
        (Image.ds.interest.growth, "interest_growth"),
        (Image.ds.interest.hobby, "interest_hobby"),
        (Image.ds.interest.party, "interest_party"),
        (Image.ds.interest.pet, "interest_pet"),
        (Image.ds.interest.study, "interest_study"),
        (Image.ds.interest.travel, "interest_travel"),
        (Image.ds.icon.arrows.down, "icon_arrows_down"),
        (Image.ds.icon.arrows.left, "icon_arrows_left"),
        (Image.ds.icon.arrows.leftDown, "icon_arrows_left_down"),
        (Image.ds.icon.arrows.leftUp, "icon_arrows_left_up"),
        (Image.ds.icon.arrows.right, "icon_arrows_right"),
        (Image.ds.icon.arrows.rightDown, "icon_arrows_right_down"),
        (Image.ds.icon.arrows.rightUp, "icon_arrows_right_up"),
        (Image.ds.icon.arrows.up, "icon_arrows_up"),
        (Image.ds.icon.backspace.filled, "icon_backspace_filled"),
        (Image.ds.icon.backspace.outlined, "icon_backspace_outlined"),
        (Image.ds.icon.bell.filled, "icon_bell_filled"),
        (Image.ds.icon.bell.outlined, "icon_bell_outlined"),
        (Image.ds.icon.bellOff.filled, "icon_bell_off_filled"),
        (Image.ds.icon.bellOff.outlined, "icon_bell_off_outlined"),
        (Image.ds.icon.bookmark.filled, "icon_bookmark_filled"),
        (Image.ds.icon.bookmark.outlined, "icon_bookmark_outlined"),
        (Image.ds.icon.calendar.filled, "icon_calendar_filled"),
        (Image.ds.icon.calendar.outlined, "icon_calendar_outlined"),
        (Image.ds.icon.camera.filled, "icon_camera_filled"),
        (Image.ds.icon.camera.outlined, "icon_camera_outlined"),
        (Image.ds.icon.chat.filled, "icon_chat_filled"),
        (Image.ds.icon.chat.outlined, "icon_chat_outlined"),
        (Image.ds.icon.check.filled, "icon_check_filled"),
        (Image.ds.icon.check.outlined, "icon_check_outlined"),
        (Image.ds.icon.chevron.down, "icon_chevron_down"),
        (Image.ds.icon.chevron.left, "icon_chevron_left"),
        (Image.ds.icon.chevron.right, "icon_chevron_right"),
        (Image.ds.icon.chevron.up, "icon_chevron_up"),
        (Image.ds.icon.chevronUpDown.filled, "icon_chevron_up_down_filled"),
        (Image.ds.icon.chevronUpDown.outlined, "icon_chevron_up_down_outlined"),
        (Image.ds.icon.chevronWide.down, "icon_chevron_wide_down"),
        (Image.ds.icon.chevronWide.left, "icon_chevron_wide_left"),
        (Image.ds.icon.chevronWide.right, "icon_chevron_wide_right"),
        (Image.ds.icon.chevronWide.up, "icon_chevron_wide_up"),
        (Image.ds.icon.close.filled, "icon_close_filled"),
        (Image.ds.icon.close.outlined, "icon_close_outlined"),
        (Image.ds.icon.crop.filled, "icon_crop_filled"),
        (Image.ds.icon.crop.outlined, "icon_crop_outlined"),
        (Image.ds.icon.cup.filled, "icon_cup_filled"),
        (Image.ds.icon.cup.outlined, "icon_cup_outlined"),
        (Image.ds.icon.delete.filled, "icon_delete_filled"),
        (Image.ds.icon.delete.outlined, "icon_delete_outlined"),
        (Image.ds.icon.download.filled, "icon_download_filled"),
        (Image.ds.icon.download.outlined, "icon_download_outlined"),
        (Image.ds.icon.envelope.filled, "icon_envelope_filled"),
        (Image.ds.icon.envelope.outlined, "icon_envelope_outlined"),
        (Image.ds.icon.eyedropper.filled, "icon_eyedropper_filled"),
        (Image.ds.icon.eyedropper.outlined, "icon_eyedropper_outlined"),
        (Image.ds.icon.filter.filled, "icon_filter_filled"),
        (Image.ds.icon.filter.outlined, "icon_filter_outlined"),
        (Image.ds.icon.flash.filled, "icon_flash_filled"),
        (Image.ds.icon.flash.outlined, "icon_flash_outlined"),
        (Image.ds.icon.folder.filled, "icon_folder_filled"),
        (Image.ds.icon.folder.outlined, "icon_folder_outlined"),
        (Image.ds.icon.folderMinus.filled, "icon_folder_minus_filled"),
        (Image.ds.icon.folderMinus.outlined, "icon_folder_minus_outlined"),
        (Image.ds.icon.folderPlus.filled, "icon_folder_plus_filled"),
        (Image.ds.icon.folderPlus.outlined, "icon_folder_plus_outlined"),
        (Image.ds.icon.folderShared.filled, "icon_folder_shared_filled"),
        (Image.ds.icon.folderShared.outlined, "icon_folder_shared_outlined"),
        (Image.ds.icon.frame.filled, "icon_frame_filled"),
        (Image.ds.icon.frame.outlined, "icon_frame_outlined"),
        (Image.ds.icon.gender.filled, "icon_gender_filled"),
        (Image.ds.icon.gender.outlined, "icon_gender_outlined"),
        (Image.ds.icon.grid.bottomWide.filled, "icon_grid_bottom_wide_filled"),
        (Image.ds.icon.grid.bottomWide.outlined, "icon_grid_bottom_wide_outlined"),
        (Image.ds.icon.grid.mosaic.filled, "icon_grid_mosaic_filled"),
        (Image.ds.icon.grid.mosaic.outlined, "icon_grid_mosaic_outlined"),
        (Image.ds.icon.grid.oneByTwo.filled, "icon_grid_one_by_two_filled"),
        (Image.ds.icon.grid.oneByTwo.outlined, "icon_grid_one_by_two_outlined"),
        (Image.ds.icon.grid.split.filled, "icon_grid_split_filled"),
        (Image.ds.icon.grid.split.outlined, "icon_grid_split_outlined"),
        (Image.ds.icon.grid.topWide.filled, "icon_grid_top_wide_filled"),
        (Image.ds.icon.grid.topWide.outlined, "icon_grid_top_wide_outlined"),
        (Image.ds.icon.grid.twoByTwo.filled, "icon_grid_two_by_two_filled"),
        (Image.ds.icon.grid.twoByTwo.outlined, "icon_grid_two_by_two_outlined"),
        (Image.ds.icon.hashtag.filled, "icon_hashtag_filled"),
        (Image.ds.icon.hashtag.outlined, "icon_hashtag_outlined"),
        (Image.ds.icon.heart.filled, "icon_heart_filled"),
        (Image.ds.icon.heart.outlined, "icon_heart_outlined"),
        (Image.ds.icon.home.filled, "icon_home_filled"),
        (Image.ds.icon.home.outlined, "icon_home_outlined"),
        (Image.ds.icon.idCard.filled, "icon_id_card_filled"),
        (Image.ds.icon.idCard.outlined, "icon_id_card_outlined"),
        (Image.ds.icon.image.filled, "icon_image_filled"),
        (Image.ds.icon.image.outlined, "icon_image_outlined"),
        (Image.ds.icon.info.filled, "icon_info_filled"),
        (Image.ds.icon.info.outlined, "icon_info_outlined"),
        (Image.ds.icon.layers.filled, "icon_layers_filled"),
        (Image.ds.icon.layers.outlined, "icon_layers_outlined"),
        (Image.ds.icon.link.filled, "icon_link_filled"),
        (Image.ds.icon.link.outlined, "icon_link_outlined"),
        (Image.ds.icon.location.filled, "icon_location_filled"),
        (Image.ds.icon.location.outlined, "icon_location_outlined"),
        (Image.ds.icon.locationArrow.filled, "icon_location_arrow_filled"),
        (Image.ds.icon.locationArrow.outlined, "icon_location_arrow_outlined"),
        (Image.ds.icon.megaphone.filled, "icon_megaphone_filled"),
        (Image.ds.icon.megaphone.outlined, "icon_megaphone_outlined"),
        (Image.ds.icon.menu.filled, "icon_menu_filled"),
        (Image.ds.icon.menu.outlined, "icon_menu_outlined"),
        (Image.ds.icon.mic.filled, "icon_mic_filled"),
        (Image.ds.icon.mic.outlined, "icon_mic_outlined"),
        (Image.ds.icon.micOff.filled, "icon_mic_off_filled"),
        (Image.ds.icon.micOff.outlined, "icon_mic_off_outlined"),
        (Image.ds.icon.moreHorizontal.filled, "icon_more_horizontal_filled"),
        (Image.ds.icon.moreHorizontal.outlined, "icon_more_horizontal_outlined"),
        (Image.ds.icon.moreVertical.filled, "icon_more_vertical_filled"),
        (Image.ds.icon.moreVertical.outlined, "icon_more_vertical_outlined"),
        (Image.ds.icon.music.filled, "icon_music_filled"),
        (Image.ds.icon.music.outlined, "icon_music_outlined"),
        (Image.ds.icon.note.filled, "icon_note_filled"),
        (Image.ds.icon.note.outlined, "icon_note_outlined"),
        (Image.ds.icon.overlay.filled, "icon_overlay_filled"),
        (Image.ds.icon.overlay.outlined, "icon_overlay_outlined"),
        (Image.ds.icon.paint.filled, "icon_paint_filled"),
        (Image.ds.icon.paint.outlined, "icon_paint_outlined"),
        (Image.ds.icon.people.filled, "icon_people_filled"),
        (Image.ds.icon.people.outlined, "icon_people_outlined"),
        (Image.ds.icon.person.filled, "icon_person_filled"),
        (Image.ds.icon.person.outlined, "icon_person_outlined"),
        (Image.ds.icon.pin.filled, "icon_pin_filled"),
        (Image.ds.icon.pin.outlined, "icon_pin_outlined"),
        (Image.ds.icon.playBox.filled, "icon_play_box_filled"),
        (Image.ds.icon.playBox.outlined, "icon_play_box_outlined"),
        (Image.ds.icon.playCircle.filled, "icon_play_circle_filled"),
        (Image.ds.icon.playCircle.outlined, "icon_play_circle_outlined"),
        (Image.ds.icon.playStack.filled, "icon_play_stack_filled"),
        (Image.ds.icon.playStack.outlined, "icon_play_stack_outlined"),
        (Image.ds.icon.plus.filled, "icon_plus_filled"),
        (Image.ds.icon.plus.outlined, "icon_plus_outlined"),
        (Image.ds.icon.poll.filled, "icon_poll_filled"),
        (Image.ds.icon.poll.outlined, "icon_poll_outlined"),
        (Image.ds.icon.popcorn.filled, "icon_popcorn_filled"),
        (Image.ds.icon.popcorn.outlined, "icon_popcorn_outlined"),
        (Image.ds.icon.question.filled, "icon_question_filled"),
        (Image.ds.icon.question.outlined, "icon_question_outlined"),
        (Image.ds.icon.questionAlt.filled, "icon_question_alt_filled"),
        (Image.ds.icon.questionAlt.outlined, "icon_question_alt_outlined"),
        (Image.ds.icon.refresh.filled, "icon_refresh_filled"),
        (Image.ds.icon.refresh.outlined, "icon_refresh_outlined"),
        (Image.ds.icon.scale.filled, "icon_scale_filled"),
        (Image.ds.icon.scale.outlined, "icon_scale_outlined"),
        (Image.ds.icon.search.filled, "icon_search_filled"),
        (Image.ds.icon.search.outlined, "icon_search_outlined"),
        (Image.ds.icon.send.filled, "icon_send_filled"),
        (Image.ds.icon.send.outlined, "icon_send_outlined"),
        (Image.ds.icon.setting.filled, "icon_setting_filled"),
        (Image.ds.icon.setting.outlined, "icon_setting_outlined"),
        (Image.ds.icon.telegram.filled, "icon_telegram_filled"),
        (Image.ds.icon.telegram.outlined, "icon_telegram_outlined"),
        (Image.ds.icon.text.filled, "icon_text_filled"),
        (Image.ds.icon.text.outlined, "icon_text_outlined"),
        (Image.ds.icon.timer.filled, "icon_timer_filled"),
        (Image.ds.icon.timer.outlined, "icon_timer_outlined"),
        (Image.ds.icon.trash.filled, "icon_trash_filled"),
        (Image.ds.icon.trash.outlined, "icon_trash_outlined"),
        (Image.ds.icon.video.filled, "icon_video_filled"),
        (Image.ds.icon.video.outlined, "icon_video_outlined"),
        (Image.ds.icon.volume.filled, "icon_volume_filled"),
        (Image.ds.icon.volume.outlined, "icon_volume_outlined"),
        (Image.ds.icon.volumeOff.filled, "icon_volume_off_filled"),
        (Image.ds.icon.volumeOff.outlined, "icon_volume_off_outlined"),
        (Image.ds.icon.xCircle.filled, "icon_x_circle_filled"),
        (Image.ds.icon.xCircle.outlined, "icon_x_circle_outlined"),
        (Image.ds.icon.zoomIn.filled, "icon_zoom_in_filled"),
        (Image.ds.icon.zoomIn.outlined, "icon_zoom_in_outlined"),
        (Image.ds.icon.zoomOut.filled, "icon_zoom_out_filled"),
        (Image.ds.icon.zoomOut.outlined, "icon_zoom_out_outlined"),
        (Image.ds.login.shortform01, "login_shortform_01"),
        (Image.ds.login.shortform02, "login_shortform_02"),
        (Image.ds.login.shortform03, "login_shortform_03"),
        (Image.ds.login.shortform04, "login_shortform_04"),
        (Image.ds.onboarding.profileDefault, "onboarding_profile_default"),
        (Image.ds.social.apple, "icon_social_apple"),
        (Image.ds.social.kakao, "icon_social_kakao"),
    ]
}
