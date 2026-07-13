import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    private struct Movie {
        let imageName: String
        let rating: Double
    }

    private weak var delegate: QuestionFactoryDelegate?
    private var currentQuestionIndex = 0

    private let movies: [Movie] = [
        Movie(imageName: "The Godfather", rating: 9.2),
        Movie(imageName: "The Dark Knight", rating: 9.0),
        Movie(imageName: "Kill Bill", rating: 8.2),
        Movie(imageName: "The Avengers", rating: 8.0),
        Movie(imageName: "Deadpool", rating: 8.0),
        Movie(imageName: "The Green Knight", rating: 6.6),
        Movie(imageName: "Old", rating: 5.8),
        Movie(imageName: "The Ice Age Adventures of Buck Wild", rating: 4.3),
        Movie(imageName: "Tesla", rating: 5.1),
        Movie(imageName: "Vivarium", rating: 5.9)
    ]

    init(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }

    func requestNextQuestion() {
        guard let movie = movies[safe: currentQuestionIndex] else {
            delegate?.didReceiveNextQuestion(question: nil)
            return
        }

        let question = QuizQuestion(
            imageName: movie.imageName,
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: movie.rating > 6
        )

        currentQuestionIndex += 1
        delegate?.didReceiveNextQuestion(question: question)
    }
}
