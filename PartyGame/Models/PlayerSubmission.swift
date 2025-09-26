//
//  PlayerSubmission.swift
//  PartyGame
//
//  Created by Fernando Sulzbach on 09/09/25.
//


import SwiftUI
import GameKit

struct PlayerSubmission: Codable {
   // let id = UUID()
    let playerID: String //PlayerRepresentable
    let phrase: String
    let imageSubmission: ImageSubmission
    var votes: Int
    
    init(playerID: String, phrase: String, imageSubmission: ImageSubmission, votes: Int) {
        self.playerID = playerID
        self.phrase = phrase
        self.imageSubmission = imageSubmission
        self.votes = votes
    }
}
