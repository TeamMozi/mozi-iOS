import SharedDesignSystem
import SwiftUI

/// 카테고리 칸 그림. 서버 이름이 시안 12개 중 하나면 그 그림, 아니면 「기타」 그림이다.
enum InterestIcon: CaseIterable {
    case hobby, growth, art, activity, friend, travel, food, pet, dessert, study, party, etc

    private static let byName: [String: InterestIcon] = [
        "취미/오락": .hobby,
        "자기 계발": .growth,
        "문화/예술": .art,
        "액티비티/스포츠": .activity,
        "친구/또래": .friend,
        "여행/나들이": .travel,
        "푸드/드링크": .food,
        "반려동물": .pet,
        "디저트": .dessert,
        "스터디": .study,
        "파티": .party,
        "기타": .etc,
    ]

    private static let images: [InterestIcon: Image] = [
        .hobby: Image.ds.interest.hobby,
        .growth: Image.ds.interest.growth,
        .art: Image.ds.interest.art,
        .activity: Image.ds.interest.activity,
        .friend: Image.ds.interest.friend,
        .travel: Image.ds.interest.travel,
        .food: Image.ds.interest.food,
        .pet: Image.ds.interest.pet,
        .dessert: Image.ds.interest.dessert,
        .study: Image.ds.interest.study,
        .party: Image.ds.interest.party,
        .etc: Image.ds.interest.etc,
    ]

    init(interestName: String) {
        self = Self.byName[interestName] ?? .etc
    }

    var image: Image {
        Self.images[self] ?? Image.ds.interest.etc
    }
}
