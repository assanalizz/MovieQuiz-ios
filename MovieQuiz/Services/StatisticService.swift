import Foundation

final class StatisticService: StatisticServiceProtocol {
    private enum Keys {
        static let gamesCount = "gamesCount"
        static let bestGameCorrect = "bestGameCorrect"
        static let bestGameTotal = "bestGameTotal"
        static let bestGameDate = "bestGameDate"
        static let totalCorrectAnswers = "totalCorrectAnswers"
        static let totalQuestions = "totalQuestions"
    }

    private let storage: UserDefaults

    init(storage: UserDefaults = .standard) {
        self.storage = storage
    }

    var gamesCount: Int {
        storage.integer(forKey: Keys.gamesCount)
    }

    var bestGame: GameRecord {
        let storedDate = storage.double(forKey: Keys.bestGameDate)
        let date = storedDate == 0
            ? Date(timeIntervalSince1970: 0)
            : Date(timeIntervalSince1970: storedDate)

        return GameRecord(
            correct: storage.integer(forKey: Keys.bestGameCorrect),
            total: storage.integer(forKey: Keys.bestGameTotal),
            date: date
        )
    }

    var totalAccuracy: Double {
        let totalQuestions = storage.integer(forKey: Keys.totalQuestions)
        guard totalQuestions > 0 else { return 0 }

        let totalCorrectAnswers = storage.integer(forKey: Keys.totalCorrectAnswers)
        return Double(totalCorrectAnswers) / Double(totalQuestions) * 100
    }

    func store(correct count: Int, total amount: Int) {
        let isFirstGame = gamesCount == 0
        let currentGame = GameRecord(correct: count, total: amount, date: Date())

        storage.set(gamesCount + 1, forKey: Keys.gamesCount)

        let allCorrectAnswers = storage.integer(forKey: Keys.totalCorrectAnswers) + count
        storage.set(allCorrectAnswers, forKey: Keys.totalCorrectAnswers)

        let allQuestions = storage.integer(forKey: Keys.totalQuestions) + amount
        storage.set(allQuestions, forKey: Keys.totalQuestions)

        if isFirstGame || currentGame.isBetterThan(bestGame) {
            storage.set(currentGame.correct, forKey: Keys.bestGameCorrect)
            storage.set(currentGame.total, forKey: Keys.bestGameTotal)
            storage.set(currentGame.date.timeIntervalSince1970, forKey: Keys.bestGameDate)
        }
    }
}
