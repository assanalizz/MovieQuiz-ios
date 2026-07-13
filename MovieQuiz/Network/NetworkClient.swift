import Foundation

final class NetworkClient: NetworkClientProtocol {
    enum NetworkError: LocalizedError {
        case invalidResponse
        case httpStatusCode(Int)
        case emptyData

        var errorDescription: String? {
            switch self {
            case .invalidResponse:
                return "Сервер вернул некорректный ответ."
            case let .httpStatusCode(code):
                return "Сервер вернул ошибку \(code)."
            case .emptyData:
                return "Сервер не вернул данные."
            }
        }
    }

    func fetch(
        url: URL,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }

            guard (200..<300).contains(httpResponse.statusCode) else {
                completion(.failure(
                    NetworkError.httpStatusCode(httpResponse.statusCode)
                ))
                return
            }

            guard let data else {
                completion(.failure(NetworkError.emptyData))
                return
            }

            completion(.success(data))
        }.resume()
    }
}
