//
//  HomeViewModel.swift
//  PartyGame
//
//  Created by Fernando Sulzbach on 09/09/25.
//
import SwiftUI
import GameKit

@Observable
class MatchRankingViewModel {
        
    let service = GameCenterService.shared
    
    func topPlayers(limit: Int = 3) -> [(Player, Int)] {
        let ranking = service.gamePlayers.map { ($0, $0.votes) }
        return ranking.sorted { $0.1 > $1.1 }.prefix(limit).map { $0 }
    }
    
    func leaveMatch() {
        service.leaveMatch()
    }
}
