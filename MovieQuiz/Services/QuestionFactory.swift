import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    enum QuestionFactoryError: LocalizedError {
        case moviesAreNotLoaded
        case invalidMovieData

        var errorDescription: String? {
            switch self {
            case .moviesAreNotLoaded:
                return "Фильмы ещё не загружены."
            case .invalidMovieData:
                return "Не удалось подготовить вопрос."
            }
        }
    }

    private weak var delegate: QuestionFactoryDelegate?

    private let moviesLoader: MoviesLoaderProtocol
    private let networkClient: NetworkClientProtocol
    private let ratingThreshold = 6.0

    private var movies: [Movie] = []
    private var currentMovieIndex = 0

    init(
        delegate: QuestionFactoryDelegate,
        moviesLoader: MoviesLoaderProtocol = MoviesLoader(),
        networkClient: NetworkClientProtocol = NetworkClient()
    ) {
        self.delegate = delegate
        self.moviesLoader = moviesLoader
        self.networkClient = networkClient
    }

    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            guard let self else { return }

            switch result {
            case let .success(movies):
                self.movies = movies.shuffled()
                self.currentMovieIndex = 0

                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.didLoadDataFromServer()
                }

            case let .failure(error):
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }

    func requestNextQuestion() {
        guard !movies.isEmpty else {
            notifyAboutError(QuestionFactoryError.moviesAreNotLoaded)
            return
        }

        if currentMovieIndex >= movies.count {
            movies.shuffle()
            currentMovieIndex = 0
        }

        let movie = movies[currentMovieIndex]
        currentMovieIndex += 1

        guard
            let imageURL = movie.imageURL,
            let rating = movie.rating
        else {
            notifyAboutError(QuestionFactoryError.invalidMovieData)
            return
        }

        networkClient.fetch(url: imageURL) { [weak self] result in
            guard let self else { return }

            switch result {
            case let .success(imageData):
                let question = QuizQuestion(
                    image: imageData,
                    text: "Рейтинг этого фильма больше чем 6?",
                    correctAnswer: rating > self.ratingThreshold
                )

                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.didReceiveNextQuestion(
                        question: question
                    )
                }

            case let .failure(error):
                self.notifyAboutError(error)
            }
        }
    }

    private func notifyAboutError(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.didFailToLoadData(with: error)
        }
    }
}
