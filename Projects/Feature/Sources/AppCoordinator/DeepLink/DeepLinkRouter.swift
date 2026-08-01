import Foundation

public enum DeepLinkRouter {
    public static func parse(_ url: URL) -> DeepLinkRoute? {
        let host = url.host?.lowercased()
        let firstPath = url.path
            .split(separator: "/")
            .map(String.init)
            .first?
            .lowercased()

        if host == "home" || firstPath == "home" {
            return .home
        }
        return nil
    }
}
