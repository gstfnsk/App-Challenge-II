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

struct HighlightDisplay: Identifiable {
    let id = UUID()
    let image: Image
    let phrase: String
    let author: String
    let points: Int
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
    
    func convertHighlights(_ highlights: [RoundHighlight]) -> [HighlightDisplay] {
        highlights.compactMap { highlight in
            guard let uiImage = UIImage(data: highlight.playerSubmission.imageSubmission.image ?? Data() ) else {
                return nil // se o Data estiver corrompido, ignora
            }
            
            let image = Image(uiImage: uiImage)
            let phrase = highlight.playerSubmission.phrase
            let author = highlight.playerName
            let points = highlight.playerSubmission.votes
            
            return HighlightDisplay(image: image, phrase: phrase, author: author, points: points)
        }
    }
    
    init(gamePlayers: [Player], service: GameCenterService = GameCenterService.shared) {
        self.gamePlayers = gamePlayers
        self.service = service
        loadAvatars(for: gamePlayers.map { $0.player })
    }
    
    func resetAllPlayersReady() {
        service.resetReadyForAllPlayers(gamePhase: .voting)
    }
    
    func avatar(for id: String) -> UIImage? {
        avatarByID[id]
    }
    
    func loadAvatars(for players: [GKPlayer]) {
        for p in players {
            p.loadPhoto(for: .small) { [weak self] img, _ in
                guard let self else { return }
                DispatchQueue.main.async {
                    self.avatarByID[p.gamePlayerID] = img
                }
            }
        }
    }
    
    func topPlayers() -> [PlayerSnapshot] {
        gamePlayers.map {
            PlayerSnapshot(id: $0.id, name: $0.player.displayName, votes: $0.votes)
        }
        .sorted { $0.votes > $1.votes }
        .map { $0 }
    }
    
    func getGameHighlights() -> [RoundHighlight] {
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
