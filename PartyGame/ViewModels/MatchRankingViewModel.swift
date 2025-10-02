//
//  HomeViewModel.swift
//  PartyGame
//
//  Created by Fernando Sulzbach on 09/09/25.
//
import SwiftUI
import GameKit

struct RoundHighlight: Identifiable {
    let id = UUID()
    let round: Int
    let playerSubmission: PlayerSubmission
    let playerName: String
}

struct PlayerSnapshot: Identifiable {
    let id: UUID
    let name: String
    let votes: Int
}

@Observable
class MatchRankingViewModel {
    let gamePlayers: [Player]
    let service = GameCenterService.shared
    var avatarByID: [String: UIImage] = [:]
    var playerSubmissions: [PlayerSubmission] {
        service.gamePlayers.flatMap { $0.submissions }
    }
    
    init(gamePlayers: [Player]) {
        self.gamePlayers = gamePlayers
    }
    
    func avatar(for id: String) -> UIImage? { avatarByID[id] }
    
    func topPlayers(limit: Int = 3) -> [PlayerSnapshot] {
        let ranking = service.gamePlayers.map {
            PlayerSnapshot(id: $0.id, name: $0.player.displayName, votes: $0.votes)
        }
        return ranking.sorted { $0.votes > $1.votes }.prefix(limit).map { $0 }
    }
    
    func remainingPlayers(limit: Int = 3) -> [(Player, Int)] {
        let ranking = gamePlayers.map { ($0, $0.votes) }
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
    
//    func highlightPictures(for playerSubmissions: [PlayerSubmission]) -> [PlayerSubmission]
//    {
//        let groupedByRound = Dictionary(grouping: playerSubmissions) { $0.round }
//        
//        var roundHighlights: [PlayerSubmission] = []
//        
//        for (round, submissionsInRound) in groupedByRound {
//            if let topSubmission = submissionsInRound.max(by: { $0.votes < $1.votes}){
//                roundHighlig
//            }
//        }
//    }

    func getRoundHighlights() -> [RoundHighlight] {
        
        let allSubmissions = gamePlayers.flatMap { $0.submissions }

        let groupedByRound = Dictionary(grouping: allSubmissions) { $0.round }

        var roundHighlights: [RoundHighlight] = []
        
        for (round, submissionsInRound) in groupedByRound {
            if let topSubmission = submissionsInRound.max(by: { $0.votes < $1.votes }) {

                if let player = gamePlayers.first(where: { $0.player.gamePlayerID == topSubmission.playerID }) {
                    let highlight = RoundHighlight(
                        round: round,
                        playerSubmission: topSubmission,
                        playerName: player.player.displayName
                    )
                    roundHighlights.append(highlight)
                }
            }
        }

        return roundHighlights.sorted { $0.round < $1.round }
    }

}
