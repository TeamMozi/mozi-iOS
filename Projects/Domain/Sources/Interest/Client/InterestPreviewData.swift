/// `InterestClient.previewValue` 의 가짜 목록. 이름과 순서는 시안 `1517:81670` 의 3열 격자를 왼쪽 위부터 가로로 읽은 순서다.
enum InterestPreviewData {
    static let hobby = Interest(id: "preview-interest-hobby", name: "취미/오락")
    static let growth = Interest(id: "preview-interest-growth", name: "자기 계발")
    static let art = Interest(id: "preview-interest-art", name: "문화/예술")
    static let activity = Interest(id: "preview-interest-activity", name: "액티비티/스포츠")
    static let friend = Interest(id: "preview-interest-friend", name: "친구/또래")
    static let travel = Interest(id: "preview-interest-travel", name: "여행/나들이")
    static let food = Interest(id: "preview-interest-food", name: "푸드/드링크")
    static let pet = Interest(id: "preview-interest-pet", name: "반려동물")
    static let dessert = Interest(id: "preview-interest-dessert", name: "디저트")
    static let study = Interest(id: "preview-interest-study", name: "스터디")
    static let party = Interest(id: "preview-interest-party", name: "파티")
    static let etc = Interest(id: "preview-interest-etc", name: "기타")

    static let all = [hobby, growth, art, activity, friend, travel, food, pet, dessert, study, party, etc]
}
