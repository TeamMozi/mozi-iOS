import SwiftUI

public extension Image {
    static let ds = DesignSystemImages()
}

public struct DesignSystemImages: Sendable {
    public let icon = DesignSystemIcons()
    public let brand = BrandImages()
    public let login = LoginImages()
    public let social = SocialImages()

    public init() {}
}

public struct BrandImages: Sendable {
    public let logo = Image(decorative: SharedDesignSystemAsset.logoMozi)

    public init() {}
}

public struct LoginImages: Sendable {
    public let shortform01 = Image(decorative: SharedDesignSystemAsset.loginShortform01)
    public let shortform02 = Image(decorative: SharedDesignSystemAsset.loginShortform02)
    public let shortform03 = Image(decorative: SharedDesignSystemAsset.loginShortform03)
    public let shortform04 = Image(decorative: SharedDesignSystemAsset.loginShortform04)

    public init() {}
}

public struct SocialImages: Sendable {
    public let apple = Image(decorative: SharedDesignSystemAsset.iconSocialApple)
    public let kakao = Image(decorative: SharedDesignSystemAsset.iconSocialKakao)

    public init() {}
}

public struct DesignSystemIcons: Sendable {
    public let arrows = ArrowsIcon()
    public let backspace = BackspaceIcon()
    public let bell = BellIcon()
    public let bellOff = BellOffIcon()
    public let bookmark = BookmarkIcon()
    public let calendar = CalendarIcon()
    public let camera = CameraIcon()
    public let chat = ChatIcon()
    public let check = CheckIcon()
    public let chevron = ChevronIcon()
    public let chevronUpDown = ChevronUpDownIcon()
    public let chevronWide = ChevronWideIcon()
    public let close = CloseIcon()
    public let crop = CropIcon()
    public let cup = CupIcon()
    public let delete = DeleteIcon()
    public let download = DownloadIcon()
    public let envelope = EnvelopeIcon()
    public let eyedropper = EyedropperIcon()
    public let filter = FilterIcon()
    public let flash = FlashIcon()
    public let folder = FolderIcon()
    public let folderMinus = FolderMinusIcon()
    public let folderPlus = FolderPlusIcon()
    public let folderShared = FolderSharedIcon()
    public let frame = FrameIcon()
    public let gender = GenderIcon()
    public let grid = GridIcon()
    public let hashtag = HashtagIcon()
    public let heart = HeartIcon()
    public let home = HomeIcon()
    public let idCard = IdCardIcon()
    public let image = ImageIcon()
    public let info = InfoIcon()
    public let layers = LayersIcon()
    public let link = LinkIcon()
    public let location = LocationIcon()
    public let locationArrow = LocationArrowIcon()
    public let megaphone = MegaphoneIcon()
    public let menu = MenuIcon()
    public let mic = MicIcon()
    public let micOff = MicOffIcon()
    public let moreHorizontal = MoreHorizontalIcon()
    public let moreVertical = MoreVerticalIcon()
    public let music = MusicIcon()
    public let note = NoteIcon()
    public let overlay = OverlayIcon()
    public let paint = PaintIcon()
    public let people = PeopleIcon()
    public let person = PersonIcon()
    public let pin = PinIcon()
    public let playBox = PlayBoxIcon()
    public let playCircle = PlayCircleIcon()
    public let playStack = PlayStackIcon()
    public let plus = PlusIcon()
    public let poll = PollIcon()
    public let popcorn = PopcornIcon()
    public let question = QuestionIcon()
    public let questionAlt = QuestionAltIcon()
    public let refresh = RefreshIcon()
    public let scale = ScaleIcon()
    public let search = SearchIcon()
    public let send = SendIcon()
    public let setting = SettingIcon()
    public let telegram = TelegramIcon()
    public let text = TextIcon()
    public let timer = TimerIcon()
    public let trash = TrashIcon()
    public let video = VideoIcon()
    public let volume = VolumeIcon()
    public let volumeOff = VolumeOffIcon()
    public let xCircle = XCircleIcon()
    public let zoomIn = ZoomInIcon()
    public let zoomOut = ZoomOutIcon()

    public init() {}
}

public struct ArrowsIcon: Sendable {
    public let down = Image(decorative: SharedDesignSystemAsset.iconArrowsDown)
    public let left = Image(decorative: SharedDesignSystemAsset.iconArrowsLeft)
    public let leftDown = Image(decorative: SharedDesignSystemAsset.iconArrowsLeftDown)
    public let leftUp = Image(decorative: SharedDesignSystemAsset.iconArrowsLeftUp)
    public let right = Image(decorative: SharedDesignSystemAsset.iconArrowsRight)
    public let rightDown = Image(decorative: SharedDesignSystemAsset.iconArrowsRightDown)
    public let rightUp = Image(decorative: SharedDesignSystemAsset.iconArrowsRightUp)
    public let up = Image(decorative: SharedDesignSystemAsset.iconArrowsUp)

    public init() {}
}

public struct BackspaceIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconBackspaceFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconBackspaceOutlined)

    public init() {}
}

public struct BellIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconBellFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconBellOutlined)

    public init() {}
}

public struct BellOffIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconBellOffFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconBellOffOutlined)

    public init() {}
}

public struct BookmarkIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconBookmarkFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconBookmarkOutlined)

    public init() {}
}

public struct CalendarIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconCalendarFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconCalendarOutlined)

    public init() {}
}

public struct CameraIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconCameraFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconCameraOutlined)

    public init() {}
}

public struct ChatIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconChatFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconChatOutlined)

    public init() {}
}

public struct CheckIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconCheckFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconCheckOutlined)

    public init() {}
}

public struct ChevronIcon: Sendable {
    public let down = Image(decorative: SharedDesignSystemAsset.iconChevronDown)
    public let left = Image(decorative: SharedDesignSystemAsset.iconChevronLeft)
    public let right = Image(decorative: SharedDesignSystemAsset.iconChevronRight)
    public let up = Image(decorative: SharedDesignSystemAsset.iconChevronUp)

    public init() {}
}

public struct ChevronUpDownIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconChevronUpDownFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconChevronUpDownOutlined)

    public init() {}
}

public struct ChevronWideIcon: Sendable {
    public let down = Image(decorative: SharedDesignSystemAsset.iconChevronWideDown)
    public let left = Image(decorative: SharedDesignSystemAsset.iconChevronWideLeft)
    public let right = Image(decorative: SharedDesignSystemAsset.iconChevronWideRight)
    public let up = Image(decorative: SharedDesignSystemAsset.iconChevronWideUp)

    public init() {}
}

public struct CloseIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconCloseFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconCloseOutlined)

    public init() {}
}

public struct CropIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconCropFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconCropOutlined)

    public init() {}
}

public struct CupIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconCupFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconCupOutlined)

    public init() {}
}

public struct DeleteIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconDeleteFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconDeleteOutlined)

    public init() {}
}

public struct DownloadIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconDownloadFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconDownloadOutlined)

    public init() {}
}

public struct EnvelopeIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconEnvelopeFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconEnvelopeOutlined)

    public init() {}
}

public struct EyedropperIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconEyedropperFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconEyedropperOutlined)

    public init() {}
}

public struct FilterIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconFilterFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconFilterOutlined)

    public init() {}
}

public struct FlashIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconFlashFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconFlashOutlined)

    public init() {}
}

public struct FolderIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconFolderFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconFolderOutlined)

    public init() {}
}

public struct FolderMinusIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconFolderMinusFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconFolderMinusOutlined)

    public init() {}
}

public struct FolderPlusIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconFolderPlusFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconFolderPlusOutlined)

    public init() {}
}

public struct FolderSharedIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconFolderSharedFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconFolderSharedOutlined)

    public init() {}
}

public struct FrameIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconFrameFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconFrameOutlined)

    public init() {}
}

public struct GenderIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconGenderFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconGenderOutlined)

    public init() {}
}

public struct GridIcon: Sendable {
    public let bottomWide = GridBottomWideIcon()
    public let mosaic = GridMosaicIcon()
    public let oneByTwo = GridOneByTwoIcon()
    public let split = GridSplitIcon()
    public let topWide = GridTopWideIcon()
    public let twoByTwo = GridTwoByTwoIcon()

    public init() {}
}

public struct GridBottomWideIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconGridBottomWideFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconGridBottomWideOutlined)

    public init() {}
}

public struct GridMosaicIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconGridMosaicFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconGridMosaicOutlined)

    public init() {}
}

public struct GridOneByTwoIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconGridOneByTwoFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconGridOneByTwoOutlined)

    public init() {}
}

public struct GridSplitIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconGridSplitFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconGridSplitOutlined)

    public init() {}
}

public struct GridTopWideIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconGridTopWideFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconGridTopWideOutlined)

    public init() {}
}

public struct GridTwoByTwoIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconGridTwoByTwoFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconGridTwoByTwoOutlined)

    public init() {}
}

public struct HashtagIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconHashtagFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconHashtagOutlined)

    public init() {}
}

public struct HeartIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconHeartFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconHeartOutlined)

    public init() {}
}

public struct HomeIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconHomeFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconHomeOutlined)

    public init() {}
}

public struct IdCardIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconIdCardFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconIdCardOutlined)

    public init() {}
}

public struct ImageIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconImageFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconImageOutlined)

    public init() {}
}

public struct InfoIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconInfoFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconInfoOutlined)

    public init() {}
}

public struct LayersIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconLayersFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconLayersOutlined)

    public init() {}
}

public struct LinkIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconLinkFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconLinkOutlined)

    public init() {}
}

public struct LocationIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconLocationFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconLocationOutlined)

    public init() {}
}

public struct LocationArrowIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconLocationArrowFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconLocationArrowOutlined)

    public init() {}
}

public struct MegaphoneIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconMegaphoneFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconMegaphoneOutlined)

    public init() {}
}

public struct MenuIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconMenuFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconMenuOutlined)

    public init() {}
}

public struct MicIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconMicFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconMicOutlined)

    public init() {}
}

public struct MicOffIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconMicOffFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconMicOffOutlined)

    public init() {}
}

public struct MoreHorizontalIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconMoreHorizontalFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconMoreHorizontalOutlined)

    public init() {}
}

public struct MoreVerticalIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconMoreVerticalFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconMoreVerticalOutlined)

    public init() {}
}

public struct MusicIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconMusicFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconMusicOutlined)

    public init() {}
}

public struct NoteIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconNoteFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconNoteOutlined)

    public init() {}
}

public struct OverlayIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconOverlayFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconOverlayOutlined)

    public init() {}
}

public struct PaintIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconPaintFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconPaintOutlined)

    public init() {}
}

public struct PeopleIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconPeopleFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconPeopleOutlined)

    public init() {}
}

public struct PersonIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconPersonFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconPersonOutlined)

    public init() {}
}

public struct PinIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconPinFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconPinOutlined)

    public init() {}
}

public struct PlayBoxIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconPlayBoxFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconPlayBoxOutlined)

    public init() {}
}

public struct PlayCircleIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconPlayCircleFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconPlayCircleOutlined)

    public init() {}
}

public struct PlayStackIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconPlayStackFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconPlayStackOutlined)

    public init() {}
}

public struct PlusIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconPlusFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconPlusOutlined)

    public init() {}
}

public struct PollIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconPollFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconPollOutlined)

    public init() {}
}

public struct PopcornIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconPopcornFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconPopcornOutlined)

    public init() {}
}

public struct QuestionIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconQuestionFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconQuestionOutlined)

    public init() {}
}

public struct QuestionAltIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconQuestionAltFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconQuestionAltOutlined)

    public init() {}
}

public struct RefreshIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconRefreshFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconRefreshOutlined)

    public init() {}
}

public struct ScaleIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconScaleFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconScaleOutlined)

    public init() {}
}

public struct SearchIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconSearchFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconSearchOutlined)

    public init() {}
}

public struct SendIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconSendFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconSendOutlined)

    public init() {}
}

public struct SettingIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconSettingFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconSettingOutlined)

    public init() {}
}

public struct TelegramIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconTelegramFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconTelegramOutlined)

    public init() {}
}

public struct TextIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconTextFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconTextOutlined)

    public init() {}
}

public struct TimerIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconTimerFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconTimerOutlined)

    public init() {}
}

public struct TrashIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconTrashFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconTrashOutlined)

    public init() {}
}

public struct VideoIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconVideoFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconVideoOutlined)

    public init() {}
}

public struct VolumeIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconVolumeFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconVolumeOutlined)

    public init() {}
}

public struct VolumeOffIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconVolumeOffFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconVolumeOffOutlined)

    public init() {}
}

public struct XCircleIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconXCircleFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconXCircleOutlined)

    public init() {}
}

public struct ZoomInIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconZoomInFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconZoomInOutlined)

    public init() {}
}

public struct ZoomOutIcon: Sendable {
    public let filled = Image(decorative: SharedDesignSystemAsset.iconZoomOutFilled)
    public let outlined = Image(decorative: SharedDesignSystemAsset.iconZoomOutOutlined)

    public init() {}
}
