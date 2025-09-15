

import SwiftUI
import GameKit

class Game: Identifiable {
    var totalRounds: Int
    var currentRound: Int
    var phrases: [String] = []
    
    init(totalRounds: Int, currentRound: Int, phrases: [String]) {
        self.totalRounds = totalRounds
        self.currentRound = currentRound
        self.phrases = phrases
    }
}
