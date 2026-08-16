import Foundation

enum Streak {
    static func advance(current: Int, lastFocusDay: Date?, sessionDay: Date, calendar: Calendar = .current) -> Int {
        guard let lastFocusDay else { return 1 }
        if calendar.isDate(lastFocusDay, inSameDayAs: sessionDay) {
            return max(current, 1)
        }
        if let dayAfter = calendar.date(byAdding: .day, value: 1, to: lastFocusDay),
           calendar.isDate(dayAfter, inSameDayAs: sessionDay) {
            return current + 1
        }
        return 1
    }
}
