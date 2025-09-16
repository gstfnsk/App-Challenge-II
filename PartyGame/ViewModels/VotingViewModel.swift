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
    let service = GameCenterService.shared

    var players: [GKPlayer] {
        service.players
    }
    
    var voter: GKPlayer {
        GKLocalPlayer.local
    }

    // Todas as submissões para a frase atual
    func submissions(for phrase: String) -> [ImageSubmission] {
        service.playerSubmissions
            .filter { $0.phrase == phrase }
            .map { $0.imageSubmission }
    }

    func voteImage(id: UUID) {
        // lógica de votar na imagem com UUID
        print("Votou na imagem \(id)")
    }
}
