import SwiftUI

struct TokenColor: Equatable, Sendable {
    let hexRGB: UInt32
    let alpha: Double

    init(hexRGB: UInt32, alpha: Double = 1.0) {
        self.hexRGB = hexRGB
        self.alpha = alpha
    }

    var color: Color { Color(hex: hexRGB, alpha: alpha) }
}

enum PrimitiveColor {
    enum Primary {
        static let _50 = TokenColor(hexRGB: 0xF0E89A)
        static let _100 = TokenColor(hexRGB: 0xEDE58C)
        static let _200 = TokenColor(hexRGB: 0xEBE17D)
        static let _300 = TokenColor(hexRGB: 0xE9DE6F)
        static let _400 = TokenColor(hexRGB: 0xD2C864)
        static let _500 = TokenColor(hexRGB: 0xBAB259)
        static let _600 = TokenColor(hexRGB: 0xA39B4E)
        static let _700 = TokenColor(hexRGB: 0x8C8543)
        static let _800 = TokenColor(hexRGB: 0x5D592C)
        static let _900 = TokenColor(hexRGB: 0x464321)
        static let _1000 = TokenColor(hexRGB: 0x2F2C16)
    }

    enum Secondary {
        static let _100 = TokenColor(hexRGB: 0xF8FBEF)
        static let _200 = TokenColor(hexRGB: 0xEFF7D6)
        static let _300 = TokenColor(hexRGB: 0xE5F2BD)
        static let _400 = TokenColor(hexRGB: 0xD3E98B)
        static let _500 = TokenColor(hexRGB: 0xD0E77C)
        static let _600 = TokenColor(hexRGB: 0xB9CF6F)
        static let _700 = TokenColor(hexRGB: 0xA2B661)
        static let _800 = TokenColor(hexRGB: 0x8B9E54)
        static let _900 = TokenColor(hexRGB: 0x748546)
    }

    enum Neutral {
        static let _0 = TokenColor(hexRGB: 0xFFFFFF)
        static let _100 = TokenColor(hexRGB: 0xE5E5E5)
        static let _200 = TokenColor(hexRGB: 0xCCCCCC)
        static let _300 = TokenColor(hexRGB: 0xB2B2B2)
        static let _400 = TokenColor(hexRGB: 0x999999)
        static let _500 = TokenColor(hexRGB: 0x808080)
        static let _600 = TokenColor(hexRGB: 0x666666)
        static let _700 = TokenColor(hexRGB: 0x4D4D4D)
        static let _800 = TokenColor(hexRGB: 0x333333)
        static let _900 = TokenColor(hexRGB: 0x1A1A1A)
        static let _1000 = TokenColor(hexRGB: 0x000000)
    }

    enum System {
        static let blue = TokenColor(hexRGB: 0x5297FF)
        static let red = TokenColor(hexRGB: 0xF96767)
        static let orange = TokenColor(hexRGB: 0xFB923C)
    }

    enum Social {
        static let kakaoYellow = TokenColor(hexRGB: 0xFEE500)
    }
}
