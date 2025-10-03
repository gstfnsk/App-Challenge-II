//
//  HomeViewModel.swift
//  PartyGame
//
//  Created by Fernando Sulzbach on 09/09/25.
//

import SwiftUI
import GameKit

// MARK: - Models
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

// MARK: - ViewModel
@Observable
class MatchRankingViewModel {
    let gamePlayers: [Player]
    let service: GameCenterService
    var avatarByID: [String: UIImage] = [:]

    var playerSubmissions: [PlayerSubmission] {
        gamePlayers.flatMap { $0.submissions }
    }

    init(gamePlayers: [Player], service: GameCenterService = GameCenterService.shared) {
        self.gamePlayers = gamePlayers
        self.service = service
//        loadAvatars(for: gamePlayers.map { $0.player })
    }

    func avatar(for id: String) -> UIImage? {
        avatarByID[id]
    }

    func topPlayers(limit: Int = 3) -> [PlayerSnapshot] {
        gamePlayers.map {
            PlayerSnapshot(id: $0.id, name: $0.player.displayName, votes: $0.votes)
        }
        .sorted { $0.votes > $1.votes }
        .prefix(limit)
        .map { $0 }
    }

    func remainingPlayers(limit: Int = 3) -> [(Player, Int)] {
        let ranking = gamePlayers.map { ($0, $0.votes) }
            .sorted { $0.1 > $1.1 }
        return Array(ranking.dropFirst(limit))
    }

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
