import XCTest
@testable import SharedDesignSystem

final class SemanticNumberTests: XCTestCase {
    func test_spacing_and_radius() {
        XCTAssertEqual(SemanticNumber.Spacing.md, 12)
        XCTAssertEqual(SemanticNumber.Radius.xsm, 4)
        XCTAssertEqual(SemanticNumber.ControlHeight.lg, 48)
        XCTAssertEqual(SemanticNumber.Dim.default, 0.4, accuracy: 0.0001)
    }

    func test_full_semantic_number_table() {
        XCTAssertEqual(SemanticNumber.Radius.none, 0)
        XCTAssertEqual(SemanticNumber.Radius.sm, 8)
        XCTAssertEqual(SemanticNumber.Radius.md, 12)
        XCTAssertEqual(SemanticNumber.Radius.lg, 16)
        XCTAssertEqual(SemanticNumber.Radius.xxlg, 24)
        XCTAssertEqual(SemanticNumber.Radius.full, 9999)

        XCTAssertEqual(SemanticNumber.Spacing.xs, 4)
        XCTAssertEqual(SemanticNumber.Spacing.sm, 8)
        XCTAssertEqual(SemanticNumber.Spacing.lg, 16)
        XCTAssertEqual(SemanticNumber.Spacing.xl, 24)
        XCTAssertEqual(SemanticNumber.Spacing.xxl, 32)

        XCTAssertEqual(SemanticNumber.Border.thin, 1)
        XCTAssertEqual(SemanticNumber.Border.thick, 2)

        XCTAssertEqual(SemanticNumber.ControlHeight.sm, 32)
        XCTAssertEqual(SemanticNumber.ControlHeight.md, 40)

        XCTAssertEqual(SemanticNumber.Dim.light, 0.2, accuracy: 0.0001)
        XCTAssertEqual(SemanticNumber.Dim.heavy, 0.6, accuracy: 0.0001)
    }

    func test_public_cgfloat_ds_paths_resolve() {
        XCTAssertEqual(CGFloat.ds.spacing.md, 12)
        XCTAssertEqual(CGFloat.ds.radius.xsm, 4)
        XCTAssertEqual(CGFloat.ds.controlHeight.lg, 48)
        XCTAssertEqual(CGFloat.ds.dim.default, 0.4, accuracy: 0.0001)
        XCTAssertEqual(CGFloat.ds.border.thin, 1)
    }
}
