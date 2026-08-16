import Foundation

protocol SessionActivityPresenting {
    func sessionDidStart(_ session: ActiveSession)
    func sessionDidEnd()
}
