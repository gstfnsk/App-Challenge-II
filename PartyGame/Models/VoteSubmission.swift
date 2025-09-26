import SwiftUI
import GameKit

struct VoteSubmission: Codable {
    let from: String
    let toPhoto: UUID
    let round: Int
    
    init(from: String, toPhoto: UUID, round: Int) {
        self.from = from
        self.toPhoto = toPhoto
        self.round = round
    }
}
