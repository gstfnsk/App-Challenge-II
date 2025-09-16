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
//        guard let game = service.game else { return false }
//        return game.phrases.count == game.totalRounds
        return true
    }
}
