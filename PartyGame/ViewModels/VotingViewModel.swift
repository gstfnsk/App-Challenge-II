//
//  VotingViewModel.swift
//  PartyGame
//
//  Created by Giulia Stefainski on 09/09/25.
//

import Foundation
import SwiftUI
import GameKit

@Observable
final class VotingViewModel {
    private let service: GameCenterService

    init(service: GameCenterService) {
        self.service = service
    }
    var players: [GKPlayer] {
        service.players
    }

    var submissions: [PlayerSubmission] = []
    
    var voter: GKPlayer {
        GKLocalPlayer.local
    }
    func voteImage(id: UUID) {
        guard let submission = submissions.first(where: { $0.imageSubmission.id == id }) else {
            print("Submission not found for id \(id)")
            return
        }
        if submission.player == voter {
            print("Cannot vote on your own image")
            return
        }
        submission.votes += 1
        print(" \(voter.displayName) voted \(submission.player.displayName)")
    }
    
    func loadImage(id: UUID) -> UIImage? { // ainda não usada
        guard let submission = submissions.first(where: { $0.id == id }) else {
            return nil
        }
        return submission.imageSubmission.uiImage
    }
}
