import Foundation

struct MoviesResponse: Decodable {
    let items: [Movie]
    let errorMessage: String?
}
