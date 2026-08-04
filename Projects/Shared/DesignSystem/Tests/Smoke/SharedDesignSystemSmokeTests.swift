import SharedDesignSystem
import SwiftUI
import XCTest

final class SharedDesignSystemSmokeTests: XCTestCase {
    func test_모듈_임포트() {
        XCTAssertNotNil(Color.red)
    }
}
