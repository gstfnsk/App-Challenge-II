// PRIMEIRO: PhraseViewModel.swift corrigido

import Foundation
import Combine
import SwiftUI
import GameKit

@Observable
final class PhraseViewModel {
    let service = GameCenterService.shared
    
    
    var selectablePhrases: [Phrase] = Array(Phrases.all.shuffled().prefix(3))
    
    var players: [GKPlayer] { service.gamePlayers.map { $0.player } }
    var readyMap: [String: Bool] { service.readyMap[.phraseSelection] ?? [:] }
    
    var hasSubmittedPhrase: Bool = false
    var isSelectionDisabled: Bool = false
    var hasInitiatedPhraseSelection: Bool = false
    
    var timerDone: Bool = false
    
    var isRunning: Bool = false
    
    private var ticker: AnyCancellable?
    var startValue: Double = 20.0
    var remaining: Double = 0
    
    init() {
      self.remaining = startValue
    }
    
    func start() {
        guard !isRunning else { return }
        isRunning = true

        ticker = Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                if self.remaining > 0 {
                    self.remaining -= 1
                } else {
                    self.timerDone = true
                    self.stop()
                }
            }
    }
    
    func stop() {
        isRunning = false
        ticker?.cancel()
        ticker = nil
    }
    
    func reset(to seconds: Double? = nil, autostart: Bool = false) {
        if let seconds { startValue = max(0.0, seconds) }
        remaining = startValue
        stop()
        if autostart { start() }
    }
    
    var allReady: Bool {
        guard !players.isEmpty else { return false }
        for p in players {
            if readyMap[p.gamePlayerID] != true { return false }
        }
        return true
    }
    
    
    func resetAllPlayersReady() {
        service.resetReadyForAllPlayers(gamePhase: .phraseSelection)
    }
    
    func startPhase() {
        print("🚀 Starting phase - resetting all states")
        
        // Reset de todas as propriedades
        hasSubmittedPhrase = false
        hasInitiatedPhraseSelection = false
        isSelectionDisabled = false
        
        // Embaralha as frases
        selectablePhrases = Array(Phrases.all.shuffled().prefix(3))
        
    }
    
    func dicePressed() {
        selectablePhrases = Array(Phrases.all.shuffled().prefix(3))
    }
    
    func submitPhrase(phrase: String) {
        guard !hasSubmittedPhrase else {
            print("⏭️ Ignoring duplicate submission")
            return
        }
        
        print("📝 Submitting phrase: \(phrase)")
        hasSubmittedPhrase = true
        isSelectionDisabled = true
        service.submitPhrase(phrase: phrase)
    }
    
    func toggleReady() {
        service.setReady(gamePhase: .phraseSelection)
    }
    
    deinit { stop() }
}
