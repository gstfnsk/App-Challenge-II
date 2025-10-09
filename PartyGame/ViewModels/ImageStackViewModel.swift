//
//  HomeViewModel.swift
//  PartyGame
//
//  Created by Fernando Sulzbach on 09/09/25.
//
import SwiftUI
import GameKit

class ImageStackViewModel: ObservableObject {
        
    private let service = GameCenterService.shared

    func submissions(for phrase: String) -> [ImageSubmission] {
        let localID = GKLocalPlayer.local.gamePlayerID
        var result: [ImageSubmission] = []
        
        for gamePlayer in service.gamePlayers {
          //  if let currentRoundSubmission = gamePlayer.submissions.first(where: { $0.round == service.currentRound }) {
            if let currentRoundSubmission = gamePlayer.submissions.first {
                result.append(currentRoundSubmission.imageSubmission)
            }
        }
        return result
    }
    
    func resetAllPlayersReady() {
      //  service.resetReadyForAllPlayers(gamePhase: .)
    }
}
