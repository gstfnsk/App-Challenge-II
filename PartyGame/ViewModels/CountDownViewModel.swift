//
//  CountDownViewModel.swift
//  Pickture
//
//  Created by Rafael Toneto on 23/09/25.
//

import SwiftUI
import Combine

final class CountDownViewModel: ObservableObject {
    @Published var remaining: Int
    @Published var isRunning: Bool = false

    private var ticker: AnyCancellable?
    private var startValue: Int

    init(from: Int = 5) {
        self.startValue = max(0, from)
        self.remaining  = max(0, from)
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true

        ticker = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                if self.remaining > 0 {
                    self.remaining -= 1
                } else {
                    self.stop()
                }
            }
    }

    func stop() {
        isRunning = false
        ticker?.cancel()
        ticker = nil
    }

    func reset(to seconds: Int? = nil, autostart: Bool = false) {
        if let seconds { startValue = max(0, seconds) }
        remaining = startValue
        stop()
        if autostart { start() }
    }

    deinit { stop() }
}
