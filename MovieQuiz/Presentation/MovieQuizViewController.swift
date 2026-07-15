import UIKit

final class MovieQuizViewController: UIViewController {
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

    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private var alertPresenter: ResultAlertPresenter?
    private var presenter: MovieQuizPresenter?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureInterface()
        alertPresenter = ResultAlertPresenter(viewController: self)

        let questionFactory: QuestionFactoryProtocol
        if ProcessInfo.processInfo.arguments.contains("UI_TESTING") {
            questionFactory = UITestQuestionFactory()
        } else {
            questionFactory = QuestionFactory()
        }

        presenter = MovieQuizPresenter(
            viewController: self,
            questionFactory: questionFactory
        )
        presenter?.viewDidLoad()
    }

    private func configureInterface() {
        view.backgroundColor = backgroundColor

        counterLabel.font = UIFont(name: "YSDisplay-Medium", size: 20)
            ?? UIFont.systemFont(ofSize: 20, weight: .medium)
        counterLabel.textColor = .white
        counterLabel.accessibilityIdentifier = "counterLabel"

        questionLabel.font = UIFont(name: "YSDisplay-Bold", size: 23)
            ?? UIFont.systemFont(ofSize: 23, weight: .bold)
        questionLabel.textColor = .white
        questionLabel.textAlignment = .center
        questionLabel.numberOfLines = 0
        questionLabel.lineBreakMode = .byWordWrapping

        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        imageView.accessibilityIdentifier = "moviePoster"
        imageView.isAccessibilityElement = true

        configureButton(noButton, title: "Нет", identifier: "noButton")
        configureButton(yesButton, title: "Да", identifier: "yesButton")
        configureLoadingIndicator()
    }

    private func configureButton(
        _ button: UIButton,
        title: String,
        identifier: String
    ) {
        let buttonFont = UIFont(name: "YSDisplay-Medium", size: 20)
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
        button.accessibilityIdentifier = identifier
    }

    private func configureLoadingIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        imageView.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ])
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter?.noButtonClicked()
    }

    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter?.yesButtonClicked()
    }
}

extension MovieQuizViewController: MovieQuizViewControllerProtocol {
    func show(quiz step: QuizStepViewModel) {
        guard let image = UIImage(data: step.image) else { return }

        imageView.image = image
        questionLabel.text = step.question
        counterLabel.text = step.questionNumber
        imageView.layer.borderWidth = 0
        noButton.isEnabled = true
        yesButton.isEnabled = true
    }

    func showLoadingIndicator() {
        activityIndicator.startAnimating()
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }

    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }

    func showAnswerResult(isCorrect: Bool) {
        imageView.layer.borderColor = (
            isCorrect ? correctBorderColor : incorrectBorderColor
        ).cgColor
        imageView.layer.borderWidth = 8
        noButton.isEnabled = false
        yesButton.isEnabled = false
    }

    func resetAnswerResult() {
        imageView.layer.borderWidth = 0
    }

    func showAlert(
        result: QuizResultsViewModel,
        completion: @escaping () -> Void
    ) {
        alertPresenter?.show(result: result, completion: completion)
    }
}
