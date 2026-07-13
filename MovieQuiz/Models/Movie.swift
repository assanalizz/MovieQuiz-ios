import Foundation

struct Movie: Decodable {
    let id: String
    let image: String?
    let imDbRating: String?

    var rating: Double? {
        guard let imDbRating else { return nil }
        return Double(imDbRating)
    }

    var imageURL: URL? {
        guard let image else { return nil }
        return URL(string: image)
    }
}
