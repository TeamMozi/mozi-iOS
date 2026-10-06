import Foundation

/// `PlaceClient.previewValue` 와 다른 Client 의 가짜 데이터가 함께 쓰는 장소·지역 견본.
enum PlacePreviewData {
    static let yongsanCinema = Place(
        name: "CGV 용산아이파크몰",
        address: "서울 용산구 한강대로23길 55",
        latitude: 37.5296,
        longitude: 126.9653
    )

    static let mangwonPark = Place(
        name: "망원한강공원",
        address: "서울 마포구 마포나루길 467",
        latitude: 37.5551,
        longitude: 126.8957
    )

    static let seongsuStreet = Place(
        name: "성수 연무장길",
        address: "서울 성동구 연무장길 1",
        latitude: 37.5427,
        longitude: 127.0560
    )

    static let seoulForest = Place(
        name: "서울숲",
        address: "서울 성동구 뚝섬로 273",
        latitude: 37.5444,
        longitude: 127.0374
    )

    static let places = [yongsanCinema, mangwonPark, seongsuStreet, seoulForest]

    static let yongsan = Region(id: "1117000000", province: "서울특별시", district: "용산구")
    static let mapo = Region(id: "1144000000", province: "서울특별시", district: "마포구")
    static let seongdong = Region(id: "1120000000", province: "서울특별시", district: "성동구")
    static let jungnang = Region(id: "1126000000", province: "서울특별시", district: "중랑구")
    static let bundang = Region(id: "4113500000", province: "경기도", district: "성남시 분당구")
    static let sejong = Region(id: "3611000000", province: "세종특별자치시", district: nil)

    static let regionGroups = [
        RegionGroup(provinceShortName: "서울", regions: [yongsan, mapo, seongdong, jungnang]),
        RegionGroup(provinceShortName: "경기", regions: [bundang]),
        RegionGroup(provinceShortName: "세종", regions: [sejong]),
    ]
}
