//
//  TimerManager.swift
//  Pickture
//
//  Created by Lorenzo Fortes on 26/09/25.
//

import Foundation
import Combine

@Observable
final class TimerManager {
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private var hasProcessedTimeout = false
    
    var timeRemaining: Int = 30
    var remainingTimeDouble: Double = 30.0
    var hasTimeRunOut: Bool = false
    
    var onTimeout: (() -> Void)?   // callback para o que fazer quando acabar
    
    func startCountdown(until target: Date) {
        timer?.invalidate()
        hasProcessedTimeout = false
        hasTimeRunOut = false
        
        updateRemaining(target: target)
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateRemaining(target: target)
        }
    }
    
    private func updateRemaining(target: Date) {
        let remainingSecondsDouble = target.timeIntervalSinceNow
        
        timeRemaining = max(0, Int(ceil(remainingSecondsDouble)))
        remainingTimeDouble = max(0.0, remainingSecondsDouble)
        
        if timeRemaining == 0 && !hasProcessedTimeout {
            timer?.invalidate()
            hasProcessedTimeout = true
            hasTimeRunOut = true
            onTimeout?()
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
}
