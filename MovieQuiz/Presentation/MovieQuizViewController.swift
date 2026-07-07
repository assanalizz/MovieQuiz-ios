import UIKit

final class MovieQuizViewController: UIViewController {

    private struct QuizQuestion {
        let imageName: String
        let question: String
        let correctAnswer: Bool
    }

    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!

    private let questions: [QuizQuestion] = [
        QuizQuestion(
            imageName: "The Godfather",
            question: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            imageName: "The Dark Knight",
            question: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            imageName: "Kill Bill",
            question: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            imageName: "The Avengers",
            question: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            imageName: "Deadpool",
            question: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            imageName: "The Green Knight",
            question: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        ),
        QuizQuestion(
            imageName: "Old",
            question: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false
        ),
        QuizQuestion(
            imageName: "The Ice Age Adventures of Buck Wild",
            question: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false
        ),
        QuizQuestion(
            imageName: "Tesla",
            question: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false
        ),
        QuizQuestion(
            imageName: "Vivarium",
            question: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false
        )
    ]

    private var currentQuestionIndex = 0
    private var correctAnswersCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true

        showCurrentQuestion()
    }

    private func showCurrentQuestion() {
        let currentQuestion = questions[currentQuestionIndex]

        imageView.image = UIImage(named: currentQuestion.imageName)
        questionLabel.text = currentQuestion.question
        counterLabel.text = "\(currentQuestionIndex + 1)/\(questions.count)"

        imageView.layer.borderWidth = 0

        noButton.isEnabled = true
        yesButton.isEnabled = true
    }

    private func checkAnswer(_ userAnswer: Bool) {
        let currentQuestion = questions[currentQuestionIndex]
        let isCorrect = userAnswer == currentQuestion.correctAnswer

        if isCorrect {
            correctAnswersCount += 1
            imageView.layer.borderColor = UIColor.systemGreen.cgColor
        } else {
            imageView.layer.borderColor = UIColor.systemRed.cgColor
        }

        imageView.layer.borderWidth = 8

        noButton.isEnabled = false
        yesButton.isEnabled = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }

            self.imageView.layer.borderWidth = 0
            self.showNextQuestionOrResults()
        }
    }

    private func showNextQuestionOrResults() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            showCurrentQuestion()
        } else {
            showResults()
        }
    }

    private func showResults() {
        let alert = UIAlertController(
            title: "Раунд окончен",
            message: "Ваш результат: \(correctAnswersCount)/\(questions.count)",
            preferredStyle: .alert
        )

        let restartAction = UIAlertAction(
            title: "Сыграть ещё раз",
            style: .default
        ) { [weak self] _ in
            self?.restartGame()
        }

        alert.addAction(restartAction)
        present(alert, animated: true)
    }

    private func restartGame() {
        currentQuestionIndex = 0
        correctAnswersCount = 0

        showCurrentQuestion()
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        checkAnswer(false)
    }

    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        checkAnswer(true)
    }
}

/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА


 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ


 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
