//
//  VoteSubmission.swift
//  Pickture
//
//  Created by Giulia Stefainski on 29/09/25.
//

import SwiftUI
import GameKit

struct VoteSubmission: Codable {
    let from: String
    let toPlayer: String
    let toPhoto: UUID
    let round: Int
    
    init(from: String, player: String , toPhoto: UUID, round: Int) {
        self.from = from
        self.toPlayer = player
        self.toPhoto = toPhoto
        self.round = round
    }
}
