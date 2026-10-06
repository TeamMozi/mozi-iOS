import Foundation

public struct Place: Equatable, Sendable {
    public var name: String
    public var address: String
    public var latitude: Double
    public var longitude: Double

    public init(
        name: String,
        address: String,
        latitude: Double,
        longitude: Double
    ) {
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
    }
}
