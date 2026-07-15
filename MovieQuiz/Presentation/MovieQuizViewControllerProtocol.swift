import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showAnswerResult(isCorrect: Bool)
    func resetAnswerResult()
    func showAlert(
        result: QuizResultsViewModel,
        completion: @escaping () -> Void
    )
}
