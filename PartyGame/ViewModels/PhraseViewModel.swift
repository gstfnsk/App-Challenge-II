//
//  PhraseViewModel.swift
//  Pickture
//
//  Created by Giulia Stefainski on 15/09/25.
//

import Foundation
import SwiftUI

@Observable
final class PhraseViewModel {
    let service = GameCenterService.shared
    
    func savePhrase(_ phrase: Phrase) {
        // Adiciona a frase no game e envia para os outros jogadores
        service.addPhrase(phrase)
    }
    
    var haveAllPlayersSubmitted: Bool {
        guard let game = service.game else { return false }
        return game.phrases.count == game.totalRounds
    }
}
