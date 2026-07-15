import XCTest

final class MovieQuizUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }

    func testYesButtonChangesQuestionNumber() {
        waitForCounter("1/10")

        app.buttons["yesButton"].tap()

        waitForCounter("2/10")
    }

    func testNoButtonChangesQuestionNumber() {
        waitForCounter("1/10")

        app.buttons["noButton"].tap()

        waitForCounter("2/10")
    }

    func testAlertAppearsAtEndOfRound() {
        answerTenQuestions()

        let alert = app.alerts["Раунд окончен"]
        XCTAssertTrue(alert.waitForExistence(timeout: 3))
        XCTAssertTrue(alert.buttons["Сыграть ещё раз"].exists)
    }

    func testAlertClosesAndCounterResets() {
        answerTenQuestions()

        let alert = app.alerts["Раунд окончен"]
        XCTAssertTrue(alert.waitForExistence(timeout: 3))
        alert.buttons["Сыграть ещё раз"].tap()

        let alertDisappeared = NSPredicate(format: "exists == false")
        expectation(for: alertDisappeared, evaluatedWith: alert)
        waitForExpectations(timeout: 2)
        waitForCounter("1/10")
    }

    private func answerTenQuestions() {
        waitForCounter("1/10")

        for questionNumber in 1...9 {
            app.buttons["yesButton"].tap()
            waitForCounter("\(questionNumber + 1)/10")
        }

        app.buttons["yesButton"].tap()
    }

    private func waitForCounter(_ value: String) {
        let counter = app.staticTexts["counterLabel"]
        XCTAssertTrue(counter.waitForExistence(timeout: 2))

        let predicate = NSPredicate(format: "label == %@", value)
        expectation(for: predicate, evaluatedWith: counter)
        waitForExpectations(timeout: 3)

        let yesButton = app.buttons["yesButton"]
        XCTAssertTrue(yesButton.waitForExistence(timeout: 2))
        let enabledPredicate = NSPredicate(format: "enabled == true")
        expectation(for: enabledPredicate, evaluatedWith: yesButton)
        waitForExpectations(timeout: 2)
    }
}
