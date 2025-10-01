//
//  HomeViewModel.swift
//  PartyGame
//
//  Created by Fernando Sulzbach on 09/09/25.
//
import SwiftUI
import GameKit

struct PlayerSnapshot: Identifiable {
    let id: UUID
    let name: String
    let votes: Int
}

@Observable
class MatchRankingViewModel {
        
    let service = GameCenterService.shared
    
    func topPlayers(limit: Int = 3) -> [PlayerSnapshot] {
        let ranking = service.gamePlayers.map {
            PlayerSnapshot(id: $0.id, name: $0.player.displayName, votes: $0.votes)
        }
        return ranking.sorted { $0.votes > $1.votes }.prefix(limit).map { $0 }
    }
    
    //var votes = 0
//    for submission in submissions {
//        votes += submission.votes
//    }
//    return votes
    
}
