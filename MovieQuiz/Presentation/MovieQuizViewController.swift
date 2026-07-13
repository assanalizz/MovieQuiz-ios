import UIKit

final class MovieQuizViewController: UIViewController {
    private enum PresentationError: LocalizedError {
        case invalidImage

        var errorDescription: String? {
            "Не удалось загрузить изображение фильма."
        }
    }

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

    private let activityIndicator = UIActivityIndicatorView(style: .large)

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

        showLoadingIndicator()
        questionFactory?.loadData()
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
        configureLoadingIndicator()
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

    private func configureLoadingIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true

        imageView.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(
                equalTo: imageView.centerXAnchor
            ),
            activityIndicator.centerYAnchor.constraint(
                equalTo: imageView.centerYAnchor
            )
        ])
    }

    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }

    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }

    private func convert(model: QuizQuestion) -> QuizStepViewModel? {
        guard let image = UIImage(data: model.image) else { return nil }

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
            showLoadingIndicator()
            questionFactory?.requestNextQuestion()
        }
    }

    private func showResults() {
        statisticService.store(
            correct: correctAnswersCount,
            total: questionsAmount
        )

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

    private func showNetworkError(_: Error) {
        let result = QuizResultsViewModel(
            title: "Что-то пошло не так(",
            text: "Не удалось загрузить данные",
            buttonText: "Попробовать ещё раз"
        )

        alertPresenter?.show(result: result) { [weak self] in
            self?.retryLoadingData()
        }
    }

    private func retryLoadingData() {
        showLoadingIndicator()
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.loadData()
    }

    private func restartGame() {
        currentQuestionIndex = 0
        correctAnswersCount = 0
        currentQuestion = nil

        showLoadingIndicator()
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
    func didLoadDataFromServer() {
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        hideLoadingIndicator()
        showNetworkError(error)
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            didFailToLoadData(
                with: QuestionFactory.QuestionFactoryError.invalidMovieData
            )
            return
        }

        guard let viewModel = convert(model: question) else {
            didFailToLoadData(with: PresentationError.invalidImage)
            return
        }

        currentQuestion = question
        hideLoadingIndicator()
        show(quiz: viewModel)
    }
}
