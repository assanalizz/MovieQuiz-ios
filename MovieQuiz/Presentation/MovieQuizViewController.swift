import UIKit

final class MovieQuizViewController: UIViewController {
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!

    private let questionsAmount = 10

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

    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex = 0
    private var correctAnswersCount = 0

    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: ResultAlertPresenter?
    private var statisticService: StatisticServiceProtocol = StatisticService()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureInterface()

        alertPresenter = ResultAlertPresenter(viewController: self)
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
    }

    private func configureInterface() {
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
    }

    private func configureButton(_ button: UIButton, title: String) {
        let buttonFont =
            UIFont(name: "YSDisplay-Medium", size: 20)
            ?? UIFont.systemFont(ofSize: 20, weight: .medium)

        let attributedTitle = NSAttributedString(
            string: title,
            attributes: [
                .font: buttonFont,
                .foregroundColor: backgroundColor
            ]
        )

        button.setAttributedTitle(attributedTitle, for: .normal)
        button.setAttributedTitle(attributedTitle, for: .disabled)
        button.backgroundColor = buttonBackgroundColor
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
    }

    private func convert(model: QuizQuestion) -> QuizStepViewModel? {
        guard let image = UIImage(named: model.imageName) else { return nil }

        return QuizStepViewModel(
            image: image,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }

    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        questionLabel.text = step.question
        counterLabel.text = step.questionNumber

        imageView.layer.borderWidth = 0
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }

    private func checkAnswer(_ userAnswer: Bool) {
        guard let currentQuestion else { return }

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
            guard let self else { return }

            self.imageView.layer.borderWidth = 0
            self.showNextQuestionOrResults()
        }
    }

    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            showResults()
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }

    private func showResults() {
        statisticService.store(correct: correctAnswersCount, total: questionsAmount)

        let bestGame = statisticService.bestGame
        let text = """
        Ваш результат: \(correctAnswersCount)/\(questionsAmount)
        Количество сыгранных квизов: \(statisticService.gamesCount)
        Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
        Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
        """

        let result = QuizResultsViewModel(
            title: "Раунд окончен",
            text: text,
            buttonText: "Сыграть ещё раз"
        )

        alertPresenter?.show(result: result) { [weak self] in
            self?.restartGame()
        }
    }

    private func restartGame() {
        currentQuestionIndex = 0
        correctAnswersCount = 0
        currentQuestion = nil

        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        checkAnswer(false)
    }

    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        checkAnswer(true)
    }
}

extension MovieQuizViewController: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard
            let question,
            let viewModel = convert(model: question)
        else {
            return
        }

        currentQuestion = question
        show(quiz: viewModel)
    }
}
