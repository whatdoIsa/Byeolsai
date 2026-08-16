import Foundation
import Testing
@testable import Byeolsai

struct StreakTests {
    let calendar = Calendar.current
    let today = Date(timeIntervalSince1970: 1_787_200_000)

    var yesterday: Date { calendar.date(byAdding: .day, value: -1, to: today)! }
    var threeDaysAgo: Date { calendar.date(byAdding: .day, value: -3, to: today)! }

    @Test func firstSessionStartsStreakAtOne() {
        #expect(Streak.advance(current: 0, lastFocusDay: nil, sessionDay: today, calendar: calendar) == 1)
    }

    @Test func sameDaySessionKeepsStreak() {
        #expect(Streak.advance(current: 3, lastFocusDay: today, sessionDay: today, calendar: calendar) == 3)
    }

    @Test func consecutiveDayIncrementsStreak() {
        #expect(Streak.advance(current: 3, lastFocusDay: yesterday, sessionDay: today, calendar: calendar) == 4)
    }

    @Test func gapResetsStreakToOne() {
        #expect(Streak.advance(current: 9, lastFocusDay: threeDaysAgo, sessionDay: today, calendar: calendar) == 1)
    }
}
