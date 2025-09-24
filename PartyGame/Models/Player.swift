//
//  PlayerSubmission.swift
//  PartyGame
//
//  Created by Fernando Sulzbach on 09/09/25.
//


import SwiftUI
import GameKit

class Player: Identifiable {
    let player: GKPlayer //PlayerRepresentable //
    let playerID: String
    var submissions: [PlayerSubmission]
    var votes: Int {
        var votes = 0
        for submission in submissions {
            votes += submission.votes
        }
        return votes
    }
    
    init (player: GKPlayer, playerID: String, submissions: [PlayerSubmission] = []) {
        self.player = player
        self.playerID = playerID
        self.submissions = submissions
    }
}
