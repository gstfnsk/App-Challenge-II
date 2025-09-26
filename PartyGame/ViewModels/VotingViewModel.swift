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
    
    var players: [GKPlayer] = []
    var readyMap: [String: Bool] = [:]
    
    init() {
        self.players = service.gamePlayers.map { $0.player }
        self.readyMap = service.readyMap
    }

//    var players: [GKPlayer] {
//        service.gamePlayers.map { $0.player }
//    }
    
    var voter: GKPlayer {
        GKLocalPlayer.local
    }
    
    func toggleReady() {
        service.toggleReady()
    }
    
    var allReady: Bool {
        guard !players.isEmpty else { return false }
        for p in players {
            if readyMap[p.gamePlayerID] != true { return false }
        }
        return true
    }

    // Todas as submissões para a frase atual
    func submissions(for phrase: String) -> [ImageSubmission] {
        service.playerSubmissions
            .filter { $0.phrase == phrase }
            .map { $0.imageSubmission }
    }
    
    func cleanAndStoreSubmissions() {
        service.cleanAndStorePlayerSubmissions()
    }

//    func voteImage(id: UUID) {
//        guard let submission = service.playerSubmissions.first(where: { $0.imageSubmission.id == id }) else {
//            print("Nenhuma submissão encontrada para essa imagem")
//            return
//        }
//        submission.votes += 1
//    }
}
