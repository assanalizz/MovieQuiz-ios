import Foundation

protocol QuestionFactoryProtocol: AnyObject {
    var delegate: QuestionFactoryDelegate? { get set }

    func loadData()
    func requestNextQuestion()
}
