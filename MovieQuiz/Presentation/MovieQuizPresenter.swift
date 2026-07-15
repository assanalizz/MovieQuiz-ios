import Foundation

final class MovieQuizPresenter {
    private weak var viewController: MovieQuizViewControllerProtocol?
    private let questionFactory: QuestionFactoryProtocol
    private let statisticService: StatisticServiceProtocol
    private let questionsAmount: Int

    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex = 0
    private var correctAnswers = 0

    init(
        viewController: MovieQuizViewControllerProtocol,
        questionFactory: QuestionFactoryProtocol = QuestionFactory(),
        statisticService: StatisticServiceProtocol = StatisticService(),
        questionsAmount: Int = 10
    ) {
        self.viewController = viewController
        self.questionFactory = questionFactory
        self.statisticService = statisticService
        self.questionsAmount = questionsAmount
        self.questionFactory.delegate = self
    }

    func viewDidLoad() {
        viewController?.showLoadingIndicator()
        questionFactory.loadData()
    }

    func yesButtonClicked() {
        didAnswer(answer: true)
    }

    func noButtonClicked() {
        didAnswer(answer: false)
    }

    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: model.image,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }

    private func didAnswer(answer: Bool) {
        guard let currentQuestion else { return }

        let isCorrect = answer == currentQuestion.correctAnswer
        if isCorrect {
            correctAnswers += 1
        }

        viewController?.showAnswerResult(isCorrect: isCorrect)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.proceedToNextQuestionOrResults()
        }
    }

    private func proceedToNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            showResults()
        } else {
            currentQuestionIndex += 1
            viewController?.resetAnswerResult()
            questionFactory.requestNextQuestion()
        }
    }

    private func showResults() {
        statisticService.store(
            correct: correctAnswers,
            total: questionsAmount
        )

        let bestGame = statisticService.bestGame
        let result = QuizResultsViewModel(
            title: "Раунд окончен",
            text: """
            Ваш результат: \(correctAnswers)/\(questionsAmount)
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
            """,
            buttonText: "Сыграть ещё раз"
        )

        viewController?.showAlert(result: result) { [weak self] in
            guard let self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.currentQuestion = nil
            self.viewController?.resetAnswerResult()
            self.questionFactory.requestNextQuestion()
        }
    }

    private func showNetworkError(_ error: Error) {
        let result = QuizResultsViewModel(
            title: "Что-то пошло не так",
            text: error.localizedDescription,
            buttonText: "Попробовать ещё раз"
        )

        viewController?.showAlert(result: result) { [weak self] in
            guard let self else { return }
            self.viewController?.showLoadingIndicator()
            self.questionFactory.loadData()
        }
    }
}

extension MovieQuizPresenter: QuestionFactoryDelegate {
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        viewController?.hideLoadingIndicator()
        showNetworkError(error)
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        currentQuestion = question
        viewController?.show(quiz: convert(model: question))
    }
}
