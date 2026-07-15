import Foundation
import XCTest
@testable import MovieQuiz

final class MoviesLoaderTests: XCTestCase {
    func testLoadMoviesSuccess() {
        let topMoviesData = makeResponseData(
            id: "top-1",
            image: "https://example.com/top.jpg",
            rating: "9.1"
        )
        let popularMoviesData = makeResponseData(
            id: "popular-1",
            image: "https://example.com/popular.jpg",
            rating: "8.4"
        )

        let networkClient = NetworkClientStub { url in
            if url == IMDbAPI.top250MoviesURL {
                return .success(topMoviesData)
            }
            return .success(popularMoviesData)
        }
        let loader = MoviesLoader(networkClient: networkClient)
        let expectation = expectation(description: "Movies are loaded")

        loader.loadMovies { result in
            switch result {
            case let .success(movies):
                XCTAssertEqual(movies.count, 2)
                XCTAssertEqual(Set(movies.map(\.id)), Set(["top-1", "popular-1"]))
            case let .failure(error):
                XCTFail("Expected success, received error: \(error)")
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testLoadMoviesFailure() {
        let expectedError = TestError.network
        let networkClient = NetworkClientStub { _ in
            .failure(expectedError)
        }
        let loader = MoviesLoader(networkClient: networkClient)
        let expectation = expectation(description: "Loading returns an error")

        loader.loadMovies { result in
            switch result {
            case .success:
                XCTFail("Expected an error")
            case let .failure(error):
                XCTAssertEqual(error as? TestError, expectedError)
            }
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    private func makeResponseData(
        id: String,
        image: String,
        rating: String
    ) -> Data {
        let json = """
        {
          "errorMessage": "",
          "items": [
            {
              "id": "\(id)",
              "image": "\(image)",
              "imDbRating": "\(rating)"
            }
          ]
        }
        """
        return Data(json.utf8)
    }
}

private final class NetworkClientStub: NetworkClientProtocol {
    private let resultProvider: (URL) -> Result<Data, Error>

    init(resultProvider: @escaping (URL) -> Result<Data, Error>) {
        self.resultProvider = resultProvider
    }

    func fetch(
        url: URL,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        completion(resultProvider(url))
    }
}

private enum TestError: Error, Equatable {
    case network
}
