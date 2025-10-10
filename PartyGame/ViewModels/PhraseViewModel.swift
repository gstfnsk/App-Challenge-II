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
    
    // Propriedades publicadas para a View
    var hasSubmittedPhrase: Bool = false
    var isSelectionDisabled: Bool = false
    var hasInitiatedPhraseSelection: Bool = false
    
    init() {
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
}
