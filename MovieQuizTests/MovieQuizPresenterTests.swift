import Foundation
import XCTest
@testable import MovieQuiz

final class MovieQuizPresenterTests: XCTestCase {
    func testConvertCreatesCorrectViewModel() {
        let viewController = MovieQuizViewControllerSpy()
        let questionFactory = QuestionFactoryStub()
        let presenter = MovieQuizPresenter(
            viewController: viewController,
            questionFactory: questionFactory,
            statisticService: StatisticServiceStub()
        )
        let imageData = Data([0, 1, 2])
        let question = QuizQuestion(
            image: imageData,
            text: "Test question",
            correctAnswer: true
        )

        let viewModel = presenter.convert(model: question)

        XCTAssertEqual(viewModel.image, imageData)
        XCTAssertEqual(viewModel.question, "Test question")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}

private final class MovieQuizViewControllerSpy: MovieQuizViewControllerProtocol {
    func show(quiz step: QuizStepViewModel) { }
    func showLoadingIndicator() { }
    func hideLoadingIndicator() { }
    func showAnswerResult(isCorrect: Bool) { }
    func resetAnswerResult() { }
    func showAlert(
        result: QuizResultsViewModel,
        completion: @escaping () -> Void
    ) { }
}

private final class QuestionFactoryStub: QuestionFactoryProtocol {
    weak var delegate: QuestionFactoryDelegate?

    func loadData() { }
    func requestNextQuestion() { }
}

private final class StatisticServiceStub: StatisticServiceProtocol {
    var gamesCount: Int = 0
    var bestGame = GameRecord(correct: 0, total: 0, date: Date())
    var totalAccuracy: Double = 0

    func store(correct count: Int, total amount: Int) { }
}
