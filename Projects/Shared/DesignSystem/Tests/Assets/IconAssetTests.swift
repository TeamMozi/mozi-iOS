@testable import SharedDesignSystem
import UIKit
import XCTest

final class IconAssetTests: XCTestCase {
    func test_아이콘_에셋_168개가_모두_불러와진다() {
        XCTAssertEqual(IconAssetNames.all.count, 168)
        XCTAssertEqual(Set(IconAssetNames.all).count, 168)

        for name in IconAssetNames.all {
            XCTAssertNotNil(
                UIImage(named: name, in: SharedDesignSystemResources.bundle, compatibleWith: nil),
                "Missing icon asset: \(name)"
            )
        }
    }

    func test_아이콘_에셋은_모두_template으로_불러와진다() {
        for name in IconAssetNames.all {
            let image = UIImage(named: name, in: SharedDesignSystemResources.bundle, compatibleWith: nil)
            XCTAssertEqual(image?.renderingMode, .alwaysTemplate, "Not template: \(name)")
        }
    }

    func test_아이콘_에셋은_모두_벡터_유지와_template_설정() throws {
        let iconFolder = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Resources/Assets.xcassets/Icon")

        for name in IconAssetNames.all {
            let url = iconFolder.appendingPathComponent("\(name).imageset/Contents.json")
            let data = try Data(contentsOf: url)
            let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any], name)
            let properties = try XCTUnwrap(json["properties"] as? [String: Any], name)
            XCTAssertEqual(properties["template-rendering-intent"] as? String, "template", name)
            XCTAssertEqual(properties["preserves-vector-representation"] as? Bool, true, name)
        }
    }
}

private enum IconAssetNames {
    static let all: [String] = [
        "icon_arrows_down",
        "icon_arrows_left",
        "icon_arrows_left_down",
        "icon_arrows_left_up",
        "icon_arrows_right",
        "icon_arrows_right_down",
        "icon_arrows_right_up",
        "icon_arrows_up",
        "icon_backspace_filled",
        "icon_backspace_outlined",
        "icon_bell_filled",
        "icon_bell_off_filled",
        "icon_bell_off_outlined",
        "icon_bell_outlined",
        "icon_bookmark_filled",
        "icon_bookmark_outlined",
        "icon_calendar_filled",
        "icon_calendar_outlined",
        "icon_camera_filled",
        "icon_camera_outlined",
        "icon_chat_filled",
        "icon_chat_outlined",
        "icon_check_filled",
        "icon_check_outlined",
        "icon_chevron_down",
        "icon_chevron_left",
        "icon_chevron_right",
        "icon_chevron_up",
        "icon_chevron_up_down_filled",
        "icon_chevron_up_down_outlined",
        "icon_chevron_wide_down",
        "icon_chevron_wide_left",
        "icon_chevron_wide_right",
        "icon_chevron_wide_up",
        "icon_close_filled",
        "icon_close_outlined",
        "icon_crop_filled",
        "icon_crop_outlined",
        "icon_cup_filled",
        "icon_cup_outlined",
        "icon_delete_filled",
        "icon_delete_outlined",
        "icon_download_filled",
        "icon_download_outlined",
        "icon_envelope_filled",
        "icon_envelope_outlined",
        "icon_eyedropper_filled",
        "icon_eyedropper_outlined",
        "icon_filter_filled",
        "icon_filter_outlined",
        "icon_flash_filled",
        "icon_flash_outlined",
        "icon_folder_filled",
        "icon_folder_minus_filled",
        "icon_folder_minus_outlined",
        "icon_folder_outlined",
        "icon_folder_plus_filled",
        "icon_folder_plus_outlined",
        "icon_folder_shared_filled",
        "icon_folder_shared_outlined",
        "icon_frame_filled",
        "icon_frame_outlined",
        "icon_gender_filled",
        "icon_gender_outlined",
        "icon_grid_bottom_wide_filled",
        "icon_grid_bottom_wide_outlined",
        "icon_grid_mosaic_filled",
        "icon_grid_mosaic_outlined",
        "icon_grid_one_by_two_filled",
        "icon_grid_one_by_two_outlined",
        "icon_grid_split_filled",
        "icon_grid_split_outlined",
        "icon_grid_top_wide_filled",
        "icon_grid_top_wide_outlined",
        "icon_grid_two_by_two_filled",
        "icon_grid_two_by_two_outlined",
        "icon_hashtag_filled",
        "icon_hashtag_outlined",
        "icon_heart_filled",
        "icon_heart_outlined",
        "icon_home_filled",
        "icon_home_outlined",
        "icon_id_card_filled",
        "icon_id_card_outlined",
        "icon_image_filled",
        "icon_image_outlined",
        "icon_info_filled",
        "icon_info_outlined",
        "icon_layers_filled",
        "icon_layers_outlined",
        "icon_link_filled",
        "icon_link_outlined",
        "icon_location_arrow_filled",
        "icon_location_arrow_outlined",
        "icon_location_filled",
        "icon_location_outlined",
        "icon_megaphone_filled",
        "icon_megaphone_outlined",
        "icon_menu_filled",
        "icon_menu_outlined",
        "icon_mic_filled",
        "icon_mic_off_filled",
        "icon_mic_off_outlined",
        "icon_mic_outlined",
        "icon_more_horizontal_filled",
        "icon_more_horizontal_outlined",
        "icon_more_vertical_filled",
        "icon_more_vertical_outlined",
        "icon_music_filled",
        "icon_music_outlined",
        "icon_note_filled",
        "icon_note_outlined",
        "icon_overlay_filled",
        "icon_overlay_outlined",
        "icon_paint_filled",
        "icon_paint_outlined",
        "icon_people_filled",
        "icon_people_outlined",
        "icon_person_filled",
        "icon_person_outlined",
        "icon_pin_filled",
        "icon_pin_outlined",
        "icon_play_box_filled",
        "icon_play_box_outlined",
        "icon_play_circle_filled",
        "icon_play_circle_outlined",
        "icon_play_stack_filled",
        "icon_play_stack_outlined",
        "icon_plus_filled",
        "icon_plus_outlined",
        "icon_poll_filled",
        "icon_poll_outlined",
        "icon_popcorn_filled",
        "icon_popcorn_outlined",
        "icon_question_alt_filled",
        "icon_question_alt_outlined",
        "icon_question_filled",
        "icon_question_outlined",
        "icon_refresh_filled",
        "icon_refresh_outlined",
        "icon_scale_filled",
        "icon_scale_outlined",
        "icon_search_filled",
        "icon_search_outlined",
        "icon_send_filled",
        "icon_send_outlined",
        "icon_setting_filled",
        "icon_setting_outlined",
        "icon_telegram_filled",
        "icon_telegram_outlined",
        "icon_text_filled",
        "icon_text_outlined",
        "icon_timer_filled",
        "icon_timer_outlined",
        "icon_trash_filled",
        "icon_trash_outlined",
        "icon_video_filled",
        "icon_video_outlined",
        "icon_volume_filled",
        "icon_volume_off_filled",
        "icon_volume_off_outlined",
        "icon_volume_outlined",
        "icon_x_circle_filled",
        "icon_x_circle_outlined",
        "icon_zoom_in_filled",
        "icon_zoom_in_outlined",
        "icon_zoom_out_filled",
        "icon_zoom_out_outlined",
    ]
}
