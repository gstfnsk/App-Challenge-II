//
//  TimerComponent.swift
//  Pickture
//
//  Created by Rafael Toneto on 17/09/25.
//

import SwiftUI

struct TimerComponent: View {
    var remainingTime: Double
    let duration: TimeInterval
    
    var textColor: Color = .darkerPurple
    var contentPadding: EdgeInsets = .init(top: 8, leading: 12, bottom: 8, trailing: 12)
    var cornerRadius: CGFloat = 16

    private var progress: Double {
        guard duration > 0 else { return 1 }
        return min(max(Double(duration - Double(remainingTime)) / duration, 0), 1)
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

                Text(formatTime(TimeInterval(remainingTime)))
                    .font(Font.custom("DynaPuff-Regular", size: 22))
                    .monospacedDigit()
                    .foregroundStyle(textColor)
            }
            .padding(contentPadding)
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
//
//#Preview {
//    VStack(spacing: 16) {
//        TimerComponent(duration: 30)
//        TimerComponent(duration: 7)
//        TimerComponent(duration: 90)
//    }
//    .padding()
//}
