import SharedDesignSystem
import SwiftUI
import XCTest

final class SharedDesignSystemSmokeTests: XCTestCase {
    func test_SharedDesignSystem_모듈_임포트_성공() {
        XCTAssertNotNil(Color.red)
    }
}
