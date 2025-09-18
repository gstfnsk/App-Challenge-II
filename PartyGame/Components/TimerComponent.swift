//
//  TimerComponent.swift
//  Pickture
//
//  Created by Rafael Toneto on 17/09/25.
//

import SwiftUI

struct TimerComponent: View {

    let duration: TimeInterval

    var font: Font = .system(size: 20, weight: .bold, design: .rounded)
    var textColor: Color = .darkerPurple
    var contentPadding: EdgeInsets = .init(top: 8, leading: 12, bottom: 8, trailing: 12)
    var cornerRadius: CGFloat = 16

    @State private var startDate: Date?
    @State private var now: Date = .init()
    @State private var isRunning = false

    private let tick = Timer.publish(every: 1.0/30.0, on: .main, in: .common).autoconnect()

    private var elapsed: TimeInterval {
        guard let startDate, isRunning else { return 0 }
        return max(0, now.timeIntervalSince(startDate))
    }

    private var remaining: TimeInterval { max(duration - elapsed, 0) }

    private var progress: Double {
        guard duration > 0 else { return 1 }
        return min(max(elapsed / duration, 0), 1)
    }

    var stage: ProgressBarComponent.Stage {
        if progress <= 0.37 { return .green }
        if progress <= 0.75 { return .yellow }
        return .red
    }

    private var backgroundImage: Image {
        switch stage {
        case .green:  return Image(.timerGreen)
        case .yellow: return Image(.timerYellow)
        case .red:    return Image(.timerRed)
        }
    }

    var body: some View {
        ZStack {
            backgroundImage

            HStack(spacing: 5) {
                Image(.timerIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 20)
                    .accessibilityHidden(true)

                Text(formatTime(remaining))
                    .font(font)
                    .monospacedDigit()
                    .foregroundStyle(textColor)
            }
            .padding(contentPadding)
        }
        .onAppear {
            guard !isRunning else { return }
            startDate = Date()
            isRunning = true
        }
        .onDisappear { isRunning = false }
        .onReceive(tick) { date in
            now = date
            if remaining <= 0 { isRunning = false }
        }
        .animation(.easeInOut(duration: 0.2), value: stage)
    }

    private func formatTime(_ t: TimeInterval) -> String {
        let total = max(0, Int(t.rounded(.down)))
        let minutes = total / 60
        let seconds = total % 60
        return "\(minutes):" + String(format: "%02d", seconds)
    }
}

#Preview {
    VStack(spacing: 16) {
        TimerComponent(duration: 30)
        TimerComponent(duration: 7)
        TimerComponent(duration: 90)
    }
    .padding()
}
