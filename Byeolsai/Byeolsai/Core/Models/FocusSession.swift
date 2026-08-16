import Foundation

enum SessionMode: String, Codable, Sendable {
    case cam
    case phoneDown
}

struct FocusSession: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let startAt: Date
    let endAt: Date
    let focusSeconds: Int
    let mode: SessionMode
    let destinationID: String
    let valid: Bool
    let hasVideoLog: Bool
}
