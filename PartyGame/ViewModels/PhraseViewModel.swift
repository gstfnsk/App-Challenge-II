// PRIMEIRO: PhraseViewModel.swift corrigido

import Foundation
import Combine
import SwiftUI
import GameKit

@Observable
final class PhraseViewModel {
    let service = GameCenterService.shared
    
    var timeRemaining: Int = 30
    var haveTimeRunOut: Bool = false
    var selectablePhrases: [Phrase] = Array(Phrases.all.shuffled().prefix(3))
    
    var players: [GKPlayer] = []
    var readyMap: [String: Bool] = [:]
    
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    private var hasProcessedTimeRunOut: Bool = false
    
    // Propriedades publicadas para a View
    var hasSubmittedPhrase: Bool = false
    var remainingTimeDouble: Double = 30.0
    var haveAllPlayersSubmitted: Bool = false
    var isSelectionDisabled: Bool = false
    var hasInitiatedPhraseSelection: Bool = false
    
    init() {
        setupObservers()
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
    
    private func setupObservers() {
        
        self.players = service.gamePlayers.map { $0.player as! GKPlayer }
        
        // Observer para o timer
        service.$timerStart
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] target in
                self?.startCountdown(until: target)
            }
            .store(in: &cancellables)
        
        service.$readyMap
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] newMap in
                        self?.readyMap = newMap[.phraseSelection] ?? [:]
                    }
                    .store(in: &cancellables)
        
        // OBSERVER PRINCIPAL - Este é o mais importante!
        service.$submittedPhrasesByPlayer
            .combineLatest(service.$gamePlayers)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (submittedPhrases, gamePlayers) in
                guard let self = self else { return }
                
                let oldValue = self.haveAllPlayersSubmitted
                let newValue = self.service.haveAllPlayersSubmittedPhrase()
                
                print("🔍 Debug - Submitted: \(submittedPhrases.count), Players: \(gamePlayers.count)")
                print("🔍 Debug - Old: \(oldValue), New: \(newValue)")
                
                if oldValue != newValue {
                    self.haveAllPlayersSubmitted = newValue
                    print("🔄 haveAllPlayersSubmitted changed from \(oldValue) to \(newValue)")
                    
                    if newValue && !self.hasInitiatedPhraseSelection {
                        self.hasInitiatedPhraseSelection = true
                        self.timer?.invalidate()
                        print("✅ All players submitted - initiating phrase selection")
                        
                        // Pequeno delay para garantir que a UI seja atualizada
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.service.initiatePhraseSelection()
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func startPhase() {
        print("🚀 Starting phase - resetting all states")
        
        // Reset de todas as propriedades
        hasSubmittedPhrase = false
        hasProcessedTimeRunOut = false
        hasInitiatedPhraseSelection = false
        haveAllPlayersSubmitted = false
        haveTimeRunOut = false
        isSelectionDisabled = false
        timeRemaining = 30
        remainingTimeDouble = 30.0
        
        // Embaralha as frases
        selectablePhrases = Array(Phrases.all.shuffled().prefix(3))
        
        service.schedulePhaseStart(delay: 30)
    }
    
    private func startCountdown(until target: Date) {
        timer?.invalidate()
        timeRemaining = 30
        updateRemaining(target: target)
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateRemaining(target: target)
        }
    }
    
    private func updateRemaining(target: Date) {
        let remainingSecondsDouble = target.timeIntervalSinceNow
        
        timeRemaining = max(0, Int(ceil(remainingSecondsDouble)))
        remainingTimeDouble = max(0.0, remainingSecondsDouble)
        
        if timeRemaining == 0 && !hasInitiatedPhraseSelection {
            timer?.invalidate()
            hasInitiatedPhraseSelection = true
            haveTimeRunOut = true
            
            print("⏰ Time ran out - initiating phrase selection")
            
            if !hasProcessedTimeRunOut {
                hasProcessedTimeRunOut = true
                submitRandomPhraseIfNeeded()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.service.initiatePhraseSelection()
            }
        }
    }
    
    private func submitRandomPhraseIfNeeded() {
        guard !hasSubmittedPhrase else { return }
        
        hasSubmittedPhrase = true
        
        if let randomPhrase = selectablePhrases.randomElement()?.text {
          //  service.submitPhrase(phrase: randomPhrase)
            print("⏰ Auto-submission: \(randomPhrase)")
        }
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
