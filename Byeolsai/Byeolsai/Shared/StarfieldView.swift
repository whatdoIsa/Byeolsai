import SwiftUI

struct StarfieldView: View {
    var speed: Double = 8

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
            Canvas { ctx, size in
                let t = context.date.timeIntervalSinceReferenceDate
                for i in 0..<90 {
                    let seed = Double(i)
                    let fx = fract(sin(seed * 12.9898) * 43758.5453)
                    let fy = fract(sin(seed * 78.233) * 24634.6345)
                    let layer = fract(sin(seed * 3.7) * 1000)
                    let starSpeed = speed * (0.3 + layer)
                    let x = fx * size.width
                    let y = (fy * size.height + t * starSpeed).truncatingRemainder(dividingBy: size.height)
                    let radius = 0.6 + layer * 1.4
                    let opacity = 0.25 + layer * 0.6
                    let rect = CGRect(x: x, y: y, width: radius, height: radius)
                    ctx.fill(Path(ellipseIn: rect), with: .color(.white.opacity(opacity)))
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func fract(_ value: Double) -> Double {
        abs(value.truncatingRemainder(dividingBy: 1))
    }
}
