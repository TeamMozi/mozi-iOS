/// 나이 하한·상한. 비어 있는 쪽은 제한이 없다. 출생연도 표시는 화면이 바꾼다.
public struct AgeRange: Equatable, Sendable {
    public var minAge: Int?
    public var maxAge: Int?

    public init(minAge: Int?, maxAge: Int?) {
        self.minAge = minAge
        self.maxAge = maxAge
    }
}
