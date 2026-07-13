import UIKit

final class ResultAlertPresenter {
    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func show(result: QuizResultsViewModel, completion: @escaping () -> Void) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert
        )

        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            completion()
        }

        alert.addAction(action)
        viewController?.present(alert, animated: true)
    }
}
