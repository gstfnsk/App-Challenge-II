//
//  PlayerSubmission.swift
//  PartyGame
//
//  Created by Fernando Sulzbach on 09/09/25.
//


import SwiftUI
import GameKit

class Player: Identifiable {
    let id = UUID()
    let player: GKPlayer //PlayerRepresentable //
    var submissions: [PlayerSubmission]
    var votes: Int {
        var votes = 0
        for submission in submissions {
            votes += submission.votes
        }
        return votes
    }
    
    init (player: GKPlayer, submissions: [PlayerSubmission] = []) {
        self.player = player
        self.submissions = submissions

    }
}
