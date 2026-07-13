import Foundation

protocol MoviesLoaderProtocol {
    func loadMovies(
        completion: @escaping (Result<[Movie], Error>) -> Void
    )
}
