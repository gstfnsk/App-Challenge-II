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
    var avatarByID: [String: UIImage] = [:]
    func avatar(for id: String) -> UIImage? { avatarByID[id] }
    
    func topPlayers(limit: Int = 3) -> [PlayerSnapshot] {
        let ranking = service.gamePlayers.map {
            PlayerSnapshot(id: $0.id, name: $0.player.displayName, votes: $0.votes)
        }
        return ranking.sorted { $0.votes > $1.votes }.prefix(limit).map { $0 }
    }
    
    func remainingPlayers(limit: Int = 3) -> [(Player, Int)] {
        let ranking = service.gamePlayers.map { ($0, $0.votes) }
            .sorted { $0.1 > $1.1 }
        return Array(ranking.dropFirst(limit))
    }
    
    private func loadAvatars(for players: [GKPlayer]) {
        for p in players {
            p.loadPhoto(for: .small) { [weak self] img, _ in
                guard let self else { return }
                DispatchQueue.main.async {
                    self.avatarByID[p.gamePlayerID] = img
                }
            }
        }
    }

}
