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
    let player: GKPlayer
    var submissions: [PlayerSubmission]
//    let ready: Bool
    
    init (player: GKPlayer, submissions: [PlayerSubmission] = []) {
        self.player = player
        self.submissions = submissions
//        self.ready = ready
    }
}
