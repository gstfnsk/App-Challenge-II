//
//  PhraseViewModel.swift
//  Pickture
//
//  Created by Giulia Stefainski on 15/09/25.
//

import Foundation
import Combine
import SwiftUI

@Observable
final class PhraseViewModel {
    let service = GameCenterService.shared

    var timeRemaining: Int = 30
    var haveTimeRunOut: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
        private var timer: Timer?
     
    init() {
        service.$timerStart
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] target in
                self?.startCountdown(until: target)
            }
            .store(in: &cancellables)
    }
    
    //MARK: Chamado quando o jogador inicia a fase
    func startPhase() {
        service.schedulePhaseStart(delay: 3) // todos começam juntos em 3s
    }
    
    private func startCountdown(until target: Date) {
        timer?.invalidate()
        updateRemaining(target: target)
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateRemaining(target: target)
        }
    }
    
    private func updateRemaining(target: Date) {
        let total = 30
        let elapsed = Int(Date().timeIntervalSince(target))
        if elapsed < 0 {
            // ainda não chegou no target
            print("⏳ aguardando começar")
            return
        }
        
        let remaining = max(total - elapsed, 0)
        timeRemaining = remaining
        print(remaining)
        if remaining == 0 {
            timer?.invalidate()
            haveTimeRunOut = true
        }
    }
    
     func submitPhrase(phrase: String) {
         service.submitPhrase(phrase: phrase)
     }
     
     func toggleReady() {
         service.toggleReady()
     }
     
     func getSubmitedPhrases() -> [String] {
         return service.getSubmittedPhrases()
     }
    
    var haveAllPlayersSubmitted: Bool {
        service.haveAllPlayersSubmittedPhrase()
    }
}
