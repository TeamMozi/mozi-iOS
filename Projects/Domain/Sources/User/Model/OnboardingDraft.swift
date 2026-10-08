import Foundation

/// 온보딩 「완료」 때 한 번에 보내는 입력. 프로필 화면이 채우고, 카테고리 화면이 `interestIDs` 를 채운다.
public struct OnboardingDraft: Equatable, Sendable {
    public var nickname: String
    public var birthDate: Date
    public var gender: Gender
    /// 비어 있으면 보내지 않는다
    public var introduction: String?
    /// 사진을 고르지 않으면 `.keep`
    public var profileImage: ImageInput
    /// 카테고리 식별자 1~`UserLimit.interestMaxCount` 개
    public var interestIDs: [String]

    public init(
        nickname: String,
        birthDate: Date,
        gender: Gender,
        introduction: String?,
        profileImage: ImageInput,
        interestIDs: [String]
    ) {
        self.nickname = nickname
        self.birthDate = birthDate
        self.gender = gender
        self.introduction = introduction
        self.profileImage = profileImage
        self.interestIDs = interestIDs
    }
}
