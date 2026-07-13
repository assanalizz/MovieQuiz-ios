import Foundation

protocol NetworkClientProtocol {
    func fetch(
        url: URL,
        completion: @escaping (Result<Data, Error>) -> Void
    )
}
