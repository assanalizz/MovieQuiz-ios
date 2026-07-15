import XCTest
@testable import MovieQuiz

final class ArrayTests: XCTestCase {
    func testSafeSubscriptReturnsElementForValidIndex() {
        let numbers = [1, 2, 3]

        XCTAssertEqual(numbers[safe: 1], 2)
    }

    func testSafeSubscriptReturnsNilForInvalidIndex() {
        let numbers = [1, 2, 3]

        XCTAssertNil(numbers[safe: 3])
    }
}
