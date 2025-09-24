//
//  ProgressBarComponent.swift
//  Pickture
//
//  Created by Rafael Toneto on 15/09/25.
//

import SwiftUI
import Combine

struct ProgressBarComponent: View {

    @Binding var progress: Double

    let duration: TimeInterval

    let height: CGFloat = 16
    let cornerRadius: CGFloat = 20
    let trackColor: Color = .ice

    init(progress: Binding<Double>) {
        self._progress = progress
        self.duration = 0
    }

    private let t1: Double = 0.37
    private let t2: Double = 0.75

    private var effectiveProgress: Double {
        progress
    }

    private var clamped: Double { min(max(effectiveProgress, 0.0), 1.0) }

    enum Stage: Equatable { case green, yellow, red }
    private var stage: Stage {
        if clamped <= t1 { return .green }
        if clamped <= t2 { return .yellow }
        return .red
    }

    private var fillGradientForStage: LinearGradient {
        switch stage {
        case .green:
            return LinearGradient(
                colors: [.lighterGreen, .darkerGreen],
                startPoint: .leading, endPoint: .trailing
            )
        case .yellow:
            return LinearGradient(
                colors: [.yellow, .orange],
                startPoint: .leading, endPoint: .trailing
            )
        case .red:
            return LinearGradient(
                colors: [.lighterRed, .darkerRed],
                startPoint: .leading, endPoint: .trailing
            )
        }
    }

    private var fillInnerShadowColor: Color {
        switch stage {
        case .green:  return .darkerGreen
        case .yellow: return .yellow
        case .red:    return .darkerRed
        }
    }

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width * clamped
            let shape = RoundedRectangle(cornerRadius: cornerRadius)

            ZStack(alignment: .leading) {
                shape
                    .fill(trackColor)
                    .innerTopShadow(
                        color: .lilac,
                        radius: 1.5,
                        yOffset: 3,
                        spread: 1,
                        cornerRadius: cornerRadius
                    )

                if width > 0 {
                    shape
                        .fill(fillGradientForStage)
                        .innerTopShadow(
                            color: fillInnerShadowColor,
                            radius: 1.5,
                            yOffset: 3,
                            spread: 1,
                            cornerRadius: cornerRadius
                        )
                        .frame(width: width)
                        .animation(.easeInOut(duration: 0.2), value: clamped)
                        .animation(.easeInOut(duration: 0.2), value: stage)
                }
            }
        }
        .frame(height: height)
    }
}

#Preview() {
    ProgressBarComponent(progress: .constant(0.5))
        .padding()
}
