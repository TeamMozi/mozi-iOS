import Foundation

public struct OnboardingDraft: Equatable, Sendable {
    public var nickname: String
    public var gender: Gender
    public var birthDate: Date
    public var interestIDs: [String]

    public init(
        nickname: String,
        gender: Gender,
        birthDate: Date,
        interestIDs: [String]
    ) {
        self.nickname = nickname
        self.gender = gender
        self.birthDate = birthDate
        self.interestIDs = interestIDs
    }
}
