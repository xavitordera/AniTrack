import Foundation

enum MediaSeasonHelper {
    static func currentSeasonAndYear(date: Date = Date()) -> (season: String, year: Int) {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)

        switch month {
        case 12, 1, 2:
            return ("WINTER", year)
        case 3, 4, 5:
            return ("SPRING", year)
        case 6, 7, 8:
            return ("SUMMER", year)
        default:
            return ("FALL", year)
        }
    }
}
