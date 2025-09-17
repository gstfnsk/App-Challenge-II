//
//  PlayerSubmission.swift
//  PartyGame
//
//  Created by Fernando Sulzbach on 09/09/25.
//


import SwiftUI
import GameKit

class PlayerSubmission: Identifiable {
    let id = UUID()
    let player: PlayerRepresentable // GKPlayer
    let phrase: String
    let imageSubmission: ImageSubmission
    var votes: Int
    
    init(player: PlayerRepresentable, phrase: String, imageSubmission: ImageSubmission, votes: Int) {
        self.player = player
        self.phrase = phrase
        self.imageSubmission = imageSubmission
        self.votes = votes
    }
}
