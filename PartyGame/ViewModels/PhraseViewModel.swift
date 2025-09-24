//
//  PhraseViewModel.swift
//  Pickture
//
//  Created by Giulia Stefainski on 15/09/25.
//

import Foundation
import Combine
import SwiftUI
import GameKit // Adiciona import para GameKit

@Observable
final class PhraseViewModel  {
    let service = GameCenterService.shared

     var timeRemaining: Int = 30
     var haveTimeRunOut: Bool = false
     var phrases: [Phrase] = Array(Phrases.all.shuffled().prefix(3))
    
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    private var hasProcessedTimeRunOut: Bool = false // Nova flag para garantir que o time-out seja processado uma vez
    
    // Propriedades publicadas para a View
    var hasSubmittedPhrase: Bool = false
    var remainingTimeDouble: Double = 30.0
    
    init() {
        service.$timerStart
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] target in
                self?.startCountdown(until: target)
            }
            .store(in: &cancellables)
        
        // Observar quando todos os jogadores submeteram a frase para parar o timer
        service.$phrases
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.haveAllPlayersSubmitted {
                    self.timer?.invalidate()
                    self.haveTimeRunOut = true // Força a transição, pois todos submeteram
                }
            }
            .store(in: &cancellables)
    }
    
    //MARK: Chamado quando o jogador inicia a fase
    func startPhase() {
        hasSubmittedPhrase = false // Reseta o estado de submissão da frase
        hasProcessedTimeRunOut = false // Reseta a flag de processamento de time-out
        service.schedulePhaseStart(delay: 30) // Alterado para 3s de atraso. O ideal é o valor da duração da fase
    }
    
    private func startCountdown(until target: Date) {
        timer?.invalidate()
        timeRemaining = 30 // Reinicia o tempo restante
        updateRemaining(target: target)
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in // Alterado para 0.1 segundo
            self?.updateRemaining(target: target)
        }
    }
    
    private func updateRemaining(target: Date) {
        let totalTime = 30.0 // Duração total da fase
        let remainingSecondsDouble = target.timeIntervalSinceNow
        
        // Garante que o tempo restante não seja negativo e arredonda para cima
        timeRemaining = max(0, Int(ceil(remainingSecondsDouble)))
        remainingTimeDouble = max(0.0, remainingSecondsDouble)
        
        if timeRemaining == 0 {
            timer?.invalidate()
            haveTimeRunOut = true
            // Garante que a submissão aleatória seja processada apenas uma vez
            if !hasProcessedTimeRunOut {
                submitRandomPhraseIfNeeded()
                // hasProcessedTimeRunOut = true // Não definiremos aqui, será dentro de submitRandomPhraseIfNeeded
            }
        }
    }
    
    private func submitRandomPhraseIfNeeded() {
        // Qualquer jogador que não submeteu uma frase ainda deve submeter uma aleatória.
        // A verificação `hasProcessedTimeRunOut` garante que isso ocorra apenas uma vez localmente por time-out.
        guard !hasSubmittedPhrase, !hasProcessedTimeRunOut else { return }
        
        // Marca que o time-out foi processado localmente para esta fase.
        hasProcessedTimeRunOut = true
        
        // Sinaliza a todos os jogadores que a auto-submissão está começando.
        service.broadcastStartAutoPhraseSubmission()
        
        // Pequeno atraso para garantir que a flag de auto-submissão seja propagada antes de submeter a frase.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            if let randomPhrase = phrases.randomElement() {
                self.submitPhrase(phrase: randomPhrase.text)
            }
        }
    }
    
    func dicePressed(){
        phrases = Array(Phrases.all.shuffled().prefix(3))
    }
    
     func submitPhrase(phrase: String) {
         service.submitPhrase(phrase: phrase)
         hasSubmittedPhrase = true
     }
     
     func toggleReady() {
         service.toggleReady()
     }
     
//     func getSubmitedPhrases() -> [String] {
//         return service.getSubmittedPhrases()
//     }
    
    var haveAllPlayersSubmitted: Bool {
        service.haveAllPlayersSubmittedPhrase()
    }
}
