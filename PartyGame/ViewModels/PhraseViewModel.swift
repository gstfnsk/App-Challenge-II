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
    
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    private var hasProcessedTimeRunOut: Bool = false // Nova flag para garantir que o time-out seja processado uma vez
    
    // Propriedades publicadas para a View
    var hasSubmittedPhrase: Bool = false
    var remainingTimeDouble: Double = 30.0
    
    //MARK: Chamado quando o jogador inicia a fase
    func startPhase() {
        hasSubmittedPhrase = false // Reseta o estado de submissão da frase
        hasProcessedTimeRunOut = false // Reseta a flag de processamento de time-out
        service.schedulePhaseStart(delay: 3)
        startCountdown(until: Date().addingTimeInterval(30))
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
        // Só tenta submeter uma frase aleatória se o jogador local for o líder,
        // nenhuma frase foi submetida ainda por este jogador ou por qualquer outro jogador,
        // o processo de auto-submissão ainda não foi iniciado por ninguém no GameCenterService,
        // e não processamos o time-out localmente ainda.
        guard service.phraseLeaderID == GKLocalPlayer.local.gamePlayerID,
              !hasSubmittedPhrase,
              !service.isPhraseSubmittedByAnyPlayer,
              !service.isAutoSubmittingPhrase,
              !hasProcessedTimeRunOut else { return }
        
        // Marca que o time-out foi processado localmente para esta fase.
        hasProcessedTimeRunOut = true
        
        // Sinaliza a todos os jogadores que a auto-submissão está começando.
        service.broadcastStartAutoPhraseSubmission()
        
        // Pequeno atraso para garantir que a flag de auto-submissão seja propagada antes de submeter a frase.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            if let randomPhrase = Phrases.all.randomElement() {
                self.submitPhrase(phrase: randomPhrase.text)
            }
        }
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
    
}
