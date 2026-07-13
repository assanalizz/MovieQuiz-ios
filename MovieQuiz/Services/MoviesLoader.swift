import Foundation

final class MoviesLoader: MoviesLoaderProtocol {
    enum MoviesLoaderError: LocalizedError {
        case invalidURL
        case apiError(String)
        case emptyMoviesList

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Не удалось сформировать адрес запроса."
            case let .apiError(message):
                return message
            case .emptyMoviesList:
                return "Список фильмов оказался пустым."
            }
        }
    }

    private let networkClient: NetworkClientProtocol
    private let decoder = JSONDecoder()

    init(networkClient: NetworkClientProtocol = NetworkClient()) {
        self.networkClient = networkClient
    }

    func loadMovies(
        completion: @escaping (Result<[Movie], Error>) -> Void
    ) {
        guard
            let top250URL = IMDbAPI.top250MoviesURL,
            let popularURL = IMDbAPI.mostPopularMoviesURL
        else {
            completion(.failure(MoviesLoaderError.invalidURL))
            return
        }

        loadMoviesList(from: top250URL) { [weak self] topResult in
            guard let self else { return }

            switch topResult {
            case let .failure(error):
                completion(.failure(error))

            case let .success(topMovies):
                self.loadMoviesList(from: popularURL) { [weak self] popularResult in
                    guard let self else { return }
                    switch popularResult {
                    case let .failure(error):
                        completion(.failure(error))

                    case let .success(popularMovies):
                        let allMovies = self.makeUniqueMovies(
                            topMovies + popularMovies
                        )

                        guard !allMovies.isEmpty else {
                            completion(.failure(
                                MoviesLoaderError.emptyMoviesList
                            ))
                            return
                        }

                        completion(.success(allMovies))
                    }
                }
            }
        }
    }

    private func loadMoviesList(
        from url: URL,
        completion: @escaping (Result<[Movie], Error>) -> Void
    ) {
        networkClient.fetch(url: url) { [weak self] result in
            guard let self else { return }

            switch result {
            case let .failure(error):
                completion(.failure(error))

            case let .success(data):
                do {
                    let response = try self.decoder.decode(
                        MoviesResponse.self,
                        from: data
                    )

                    if
                        let message = response.errorMessage,
                        !message.isEmpty
                    {
                        completion(.failure(
                            MoviesLoaderError.apiError(message)
                        ))
                        return
                    }

                    let validMovies = response.items.filter {
                        $0.rating != nil && $0.imageURL != nil
                    }

                    completion(.success(validMovies))
                } catch {
                    completion(.failure(error))
                }
            }
        }
    }

    private func makeUniqueMovies(_ movies: [Movie]) -> [Movie] {
        var usedIdentifiers = Set<String>()

        return movies.filter { movie in
            usedIdentifiers.insert(movie.id).inserted
        }
    }
}
