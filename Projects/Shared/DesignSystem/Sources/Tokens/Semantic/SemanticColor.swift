import Foundation

/// Clear backgrounds for outlined/text default states are represented as
/// `TokenColor(hexRGB: 0x000000, alpha: 0)` so they stay testable as TokenColor.
enum SemanticColor {
    enum Button {
        enum Primary {
            static let background = Background()
            static let content = Content()

            struct Background {
                let `default` = PrimitiveColor.Primary._300
                let pressed = PrimitiveColor.Primary._600
                let disabled = PrimitiveColor.Primary._50
            }

            struct Content {
                let `default` = PrimitiveColor.Neutral._1000
                let pressed = PrimitiveColor.Neutral._1000
                let disabled = PrimitiveColor.Neutral._500
            }
        }

        enum Secondary {
            static let background = Background()
            static let content = Content()

            struct Background {
                let `default` = PrimitiveColor.Secondary._500
                let pressed = PrimitiveColor.Secondary._800
                let disabled = PrimitiveColor.Secondary._200
            }

            struct Content {
                let `default` = PrimitiveColor.Neutral._1000
                let pressed = PrimitiveColor.Neutral._1000
                let disabled = PrimitiveColor.Neutral._500
            }
        }

        enum Outlined {
            static let background = Background()
            static let content = Content()
            static let border = Border()

            struct Background {
                let `default` = TokenColor(hexRGB: 0x000000, alpha: 0)
                let pressed = PrimitiveColor.Primary._900
                let disabled = PrimitiveColor.Primary._800
            }

            struct Content {
                let `default` = PrimitiveColor.Primary._300
                let pressed = PrimitiveColor.Primary._300
                let disabled = PrimitiveColor.Primary._700
            }

            struct Border {
                let `default` = PrimitiveColor.Primary._300
                let pressed = PrimitiveColor.Primary._300
                let disabled = PrimitiveColor.Primary._700
            }
        }

        enum Text {
            static let background = Background()
            static let content = Content()

            struct Background {
                let `default` = TokenColor(hexRGB: 0x000000, alpha: 0)
                let pressed = PrimitiveColor.Primary._900
                let disabled = PrimitiveColor.Primary._800
            }

            struct Content {
                let `default` = PrimitiveColor.Primary._300
                let pressed = PrimitiveColor.Primary._300
                let disabled = PrimitiveColor.Primary._700
            }
        }
    }

    enum Text {
        enum Neutral {
            static let black = PrimitiveColor.Neutral._1000
            static let darker = PrimitiveColor.Neutral._800
            static let dark = PrimitiveColor.Neutral._700
            static let basic = PrimitiveColor.Neutral._500
            static let light = PrimitiveColor.Neutral._300
            static let lighter = PrimitiveColor.Neutral._100
            static let white = PrimitiveColor.Neutral._0
        }

        enum Primary {
            static let basic = PrimitiveColor.Primary._300
            static let dark = PrimitiveColor.Primary._500
            static let darker = PrimitiveColor.Primary._700
        }

        enum Secondary {
            static let basic = PrimitiveColor.Secondary._500
            static let darker = PrimitiveColor.Secondary._800
        }
    }

    enum Background {
        static let black = PrimitiveColor.Neutral._1000
        static let grayDarker = PrimitiveColor.Neutral._900
        static let grayDark = PrimitiveColor.Neutral._800
    }

    enum Border {
        enum Primary {
            static let basic = PrimitiveColor.Primary._300
            static let dark = PrimitiveColor.Primary._500
            static let darker = PrimitiveColor.Primary._700
        }

        enum Neutral {
            static let lighter = PrimitiveColor.Neutral._100
            static let light = PrimitiveColor.Neutral._300
            static let basic = PrimitiveColor.Neutral._500
            static let dark = PrimitiveColor.Neutral._700
            static let darker = PrimitiveColor.Neutral._800
        }
    }

    enum Social {
        static let kakao = PrimitiveColor.Social.kakaoYellow
        static let kakaoContent = PrimitiveColor.Neutral._1000
        static let appleBackground = PrimitiveColor.Neutral._0
        static let appleBorder = PrimitiveColor.Neutral._1000
        static let appleContent = PrimitiveColor.Neutral._1000
    }

    enum Dim {
        static let light = TokenColor(hexRGB: 0x000000, alpha: Double(PrimitiveNumber.Dim.light))
        static let `default` = TokenColor(hexRGB: 0x000000, alpha: Double(PrimitiveNumber.Dim.default))
        static let heavy = TokenColor(hexRGB: 0x000000, alpha: Double(PrimitiveNumber.Dim.heavy))
    }
}
