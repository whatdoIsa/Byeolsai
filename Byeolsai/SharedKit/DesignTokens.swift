import SwiftUI

enum DS {
    static let background = Color(red: 0.043, green: 0.055, blue: 0.102)
    static let surface = Color(red: 0.090, green: 0.106, blue: 0.180)
    static let surfaceElevated = Color(red: 0.133, green: 0.153, blue: 0.247)
    static let accent = Color(red: 0.192, green: 0.510, blue: 0.965)
    static let textPrimary = Color.white
    static let textSecondary = Color(red: 0.612, green: 0.647, blue: 0.702)
    static let success = Color(red: 0.0, green: 0.784, blue: 0.588)
    static let warning = Color(red: 1.0, green: 0.722, blue: 0.0)

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    static let cornerRadius: CGFloat = 16
}
