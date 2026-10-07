@testable import Feature
import ThirdParty
import XCTest

final class FeatureLogClassificationTests: XCTestCase {
    func test_띄운_화면_상태가_생기고_사라지면_present_dismiss로_본다() {
        struct SheetState: Equatable {
            var query = ""
        }

        struct HostState: Equatable {
            var sheet: PresentationState<SheetState> = PresentationState(wrappedValue: nil)
            var isLoading = false
        }

        let dismissed = HostState()
        var presented = HostState()
        presented.sheet = PresentationState(wrappedValue: SheetState(query: "cafe"))
        presented.isLoading = true

        let presentChange = FeatureLogStateDiff.changedFields(from: dismissed, to: presented)
            .first { $0.field == "sheet" }
        XCTAssertEqual(presentChange?.from, "nil")
        XCTAssertEqual(presentChange?.to, "presented")
        XCTAssertEqual(presentChange?.isPresentation, true)
        XCTAssertEqual(presentChange.flatMap(FeatureLogStateDiff.navigationStyle(for:)), .present)

        let dismissChange = FeatureLogStateDiff.changedFields(from: presented, to: dismissed)
            .first { $0.field == "sheet" }
        XCTAssertEqual(dismissChange?.from, "presented")
        XCTAssertEqual(dismissChange?.to, "nil")
        XCTAssertEqual(dismissChange.flatMap(FeatureLogStateDiff.navigationStyle(for:)), .dismiss)

        XCTAssertNil(
            FeatureLogStateDiff.presentationWrappedValue(from: PresentationState<SheetState>(wrappedValue: nil))
        )
        XCTAssertNotNil(
            FeatureLogStateDiff.presentationWrappedValue(from: PresentationState(wrappedValue: SheetState(query: "x")))
        )
    }

    func test_children에_있는_이름과_delegate_path는_액션으로_찍지_않는다() {
        let children: Set<String> = ["shortform", "myPage"]

        XCTAssertFalse(shouldLog("shortform", children: children))
        XCTAssertFalse(shouldLog("myPage", children: children))
        XCTAssertFalse(shouldLog("delegate", children: []))
        XCTAssertFalse(shouldLog("path", children: []))

        XCTAssertTrue(shouldLog("tabSelected", children: children))
        XCTAssertTrue(shouldLog("myPage", children: []))
    }

    func test_자기_Result_실패면_작업이름과_오류이름을_꺼낸다() {
        enum SampleAction {
            case loginResponse(Result<String, SampleError>)
            case onAppear
        }

        enum SampleError: Error, Equatable {
            case network
            case cancelled
        }

        let failure = SampleAction.loginResponse(.failure(.network))
        let info = FeatureLogActionParser.failureInfo(
            from: failure,
            parsed: FeatureLogActionParser.nameAndPayload(failure),
            children: []
        )
        XCTAssertEqual(info?.operation, "login")
        XCTAssertEqual(info?.error, "network")

        let success = SampleAction.loginResponse(.success("ok"))
        XCTAssertNil(
            FeatureLogActionParser.failureInfo(
                from: success,
                parsed: FeatureLogActionParser.nameAndPayload(success),
                children: []
            )
        )

        XCTAssertNil(
            FeatureLogActionParser.failureInfo(
                from: SampleAction.onAppear,
                parsed: FeatureLogActionParser.nameAndPayload(SampleAction.onAppear),
                children: []
            )
        )
    }

    func test_children_자식_액션_안의_실패는_부모_오류가_아니다() {
        enum ChildAction {
            case loginResponse(Result<String, SampleError>)
        }

        enum ParentAction {
            case login(ChildAction)
            case bootstrapResponse(Result<String?, SampleError>)
        }

        enum SampleError: Error, Equatable {
            case network
        }

        let nested = ParentAction.login(.loginResponse(.failure(.network)))
        XCTAssertNil(
            FeatureLogActionParser.failureInfo(
                from: nested,
                parsed: FeatureLogActionParser.nameAndPayload(nested),
                children: ["login"]
            )
        )

        let own = ParentAction.bootstrapResponse(.failure(.network))
        let info = FeatureLogActionParser.failureInfo(
            from: own,
            parsed: FeatureLogActionParser.nameAndPayload(own),
            children: ["login"]
        )
        XCTAssertEqual(info?.operation, "bootstrap")
        XCTAssertEqual(info?.error, "network")
    }

    private func shouldLog(_ name: String, children: Set<String>) -> Bool {
        FeatureLogActionParser.shouldLogAction(.init(name: name, payload: nil), children: children)
    }
}
