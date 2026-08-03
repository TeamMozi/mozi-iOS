import SharedUtils
import XCTest

final class LockedTests: XCTestCase {
    func test_withLock_mutates() {
        let locked = Locked(0)
        locked.withLock { value in
            value += 2
        }
        XCTAssertEqual(locked.read { $0 }, 2)
    }

    func test_concurrent_increments() {
        let locked = Locked(0)
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "locked.test", attributes: .concurrent)

        for _ in 0..<1000 {
            group.enter()
            queue.async {
                locked.withLock { value in
                    value += 1
                }
                group.leave()
            }
        }

        XCTAssertEqual(group.wait(timeout: .now() + 5), .success)
        XCTAssertEqual(locked.read { $0 }, 1000)
    }
}
