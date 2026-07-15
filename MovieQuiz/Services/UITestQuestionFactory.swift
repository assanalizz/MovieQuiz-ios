import Foundation

final class UITestQuestionFactory: QuestionFactoryProtocol {
    weak var delegate: QuestionFactoryDelegate?

    private var currentQuestionIndex = 0

    private let firstPosterData = Data(base64Encoded:
        "iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAYAAADED76LAAAAFklEQVR4nGP8z8DwnwEPYMInOXwUAAASWwIOH0pJXQAAAABJRU5ErkJggg=="
    ) ?? Data()

    private let secondPosterData = Data(base64Encoded:
        "iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAYAAADED76LAAAAFklEQVR4nGNkYPj/nwEPYMInOXwUAAAQXQIOZWZ6QQAAAABJRU5ErkJggg=="
    ) ?? Data()

    func loadData() {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.didLoadDataFromServer()
        }
    }

    func requestNextQuestion() {
        let isEvenQuestion = currentQuestionIndex.isMultiple(of: 2)
        let question = QuizQuestion(
            image: isEvenQuestion ? firstPosterData : secondPosterData,
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: isEvenQuestion
        )
        currentQuestionIndex += 1

        DispatchQueue.main.async { [weak self] in
            self?.delegate?.didReceiveNextQuestion(question: question)
        }
    }
}
