import Foundation

enum IMDbAPI {
    static let apiKey = "k_zcuw1ytf"

    private static let baseURL = "https://tv-api.com/en/API"

    static var top250MoviesURL: URL? {
        URL(string: "\(baseURL)/Top250Movies/\(apiKey)")
    }

    static var mostPopularMoviesURL: URL? {
        URL(string: "\(baseURL)/MostPopularMovies/\(apiKey)")
    }
}
