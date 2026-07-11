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

    private let backgroundColor = UIColor(
        red: 26.0 / 255.0,
        green: 28.0 / 255.0,
        blue: 35.0 / 255.0,
        alpha: 1
    )

    private let buttonBackgroundColor = UIColor(
        red: 245.0 / 255.0,
        green: 245.0 / 255.0,
        blue: 245.0 / 255.0,
        alpha: 1
    )

    private let correctBorderColor = UIColor(
        red: 95.0 / 255.0,
        green: 194.0 / 255.0,
        blue: 142.0 / 255.0,
        alpha: 1
    )

    private let incorrectBorderColor = UIColor(
        red: 245.0 / 255.0,
        green: 107.0 / 255.0,
        blue: 108.0 / 255.0,
        alpha: 1
    )

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

        view.backgroundColor = backgroundColor

        counterLabel.font =
            UIFont(name: "YSDisplay-Medium", size: 20)
            ?? UIFont.systemFont(ofSize: 20, weight: .medium)
        counterLabel.textColor = .white

        questionLabel.font =
            UIFont(name: "YSDisplay-Bold", size: 23)
            ?? UIFont.systemFont(ofSize: 23, weight: .bold)
        questionLabel.textColor = .white
        questionLabel.textAlignment = .center
        questionLabel.numberOfLines = 0
        questionLabel.lineBreakMode = .byWordWrapping

        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true

        configureButton(noButton, title: "Нет")
        configureButton(yesButton, title: "Да")

        showCurrentQuestion()
    }

    private func configureButton(_ button: UIButton, title: String) {
        let buttonFont =
            UIFont(name: "YSDisplay-Medium", size: 20)
            ?? UIFont.systemFont(ofSize: 20, weight: .medium)

        let title = NSAttributedString(
            string: title,
            attributes: [
                .font: buttonFont,
                .foregroundColor: backgroundColor
            ]
        )

        button.setAttributedTitle(title, for: .normal)
        button.setAttributedTitle(title, for: .disabled)
        button.backgroundColor = buttonBackgroundColor
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
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
            imageView.layer.borderColor = correctBorderColor.cgColor
        } else {
            imageView.layer.borderColor = incorrectBorderColor.cgColor
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
