import SwiftUI

public extension Image {
    func iconSize(_ size: CGFloat) -> some View {
        resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }
}
