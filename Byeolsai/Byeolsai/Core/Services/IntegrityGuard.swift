import Foundation

struct IntegrityVerdict: Equatable, Sendable {
    let creditedSeconds: Int
    let isValid: Bool
}

struct IntegrityGuard: Sendable {
    var minimumSessionSeconds: Int = 60
    var singleSessionCapSeconds: Int = 6 * 3600
    var dailyCapSeconds: Int = 16 * 3600

    func evaluate(rawSeconds: Int, todayAccumulatedSeconds: Int) -> IntegrityVerdict {
        guard rawSeconds >= minimumSessionSeconds else {
            return IntegrityVerdict(creditedSeconds: 0, isValid: false)
        }
        let capped = min(rawSeconds, singleSessionCapSeconds)
        let dailyAllowance = max(0, dailyCapSeconds - todayAccumulatedSeconds)
        let credited = min(capped, dailyAllowance)
        return IntegrityVerdict(creditedSeconds: credited, isValid: credited > 0)
    }
}
