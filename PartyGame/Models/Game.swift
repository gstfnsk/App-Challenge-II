

import SwiftUI
import GameKit

class Game: Identifiable {
    var totalRounds: Int
    var currentRound: Int
    var phrases: [String] = []
    
    init(playersCount: Int) {
        self.totalRounds = playersCount
        self.currentRound = 0
        self.phrases = []
    }
    
    func addPhrase(_ phrase: String) {
        phrases.append(phrase)
    }
}
