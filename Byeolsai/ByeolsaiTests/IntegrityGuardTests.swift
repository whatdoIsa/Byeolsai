import Testing
@testable import Byeolsai

struct IntegrityGuardTests {
    let guardrail = IntegrityGuard()

    @Test func rejectsSessionsUnderOneMinute() {
        let verdict = guardrail.evaluate(rawSeconds: 59, todayAccumulatedSeconds: 0)
        #expect(verdict.creditedSeconds == 0)
        #expect(!verdict.isValid)
    }

    @Test func creditsNormalSessionFully() {
        let verdict = guardrail.evaluate(rawSeconds: 1500, todayAccumulatedSeconds: 0)
        #expect(verdict.creditedSeconds == 1500)
        #expect(verdict.isValid)
    }

    @Test func capsSingleSessionAtSixHours() {
        let verdict = guardrail.evaluate(rawSeconds: 10 * 3600, todayAccumulatedSeconds: 0)
        #expect(verdict.creditedSeconds == 6 * 3600)
        #expect(verdict.isValid)
    }

    @Test func respectsRemainingDailyAllowance() {
        let verdict = guardrail.evaluate(rawSeconds: 2 * 3600, todayAccumulatedSeconds: 15 * 3600)
        #expect(verdict.creditedSeconds == 3600)
        #expect(verdict.isValid)
    }

    @Test func invalidatesWhenDailyCapReached() {
        let verdict = guardrail.evaluate(rawSeconds: 3600, todayAccumulatedSeconds: 16 * 3600)
        #expect(verdict.creditedSeconds == 0)
        #expect(!verdict.isValid)
    }
}
