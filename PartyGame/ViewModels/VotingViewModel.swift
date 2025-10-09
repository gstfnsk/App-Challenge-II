//
//  VotingViewModel.swift
//  PartyGame
//
//  Created by Giulia Stefainski on 09/09/25.
//

import Foundation
import SwiftUI
import GameKit
import Combine

@Observable
final class VotingViewModel {
    let service = GameCenterService.shared
    
    private var timer: Timer?
    var hasProcessedTimeRunOut: Bool = false
    var remainingTimeDouble: Double = 30.0
    var timeRemaining: Int = 30
    
    var players: [GKPlayer] { service.gamePlayers.map { $0.player } }
    var readyMap: [String: Bool] { service.readyMap[.voting] ?? [:] }
    
    var allReady: Bool {
        guard !players.isEmpty else { return false }
        for p in players {
            if readyMap[p.gamePlayerID] != true { return false }
        }
        return true
    }
    
    init() {
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    var voter: GKPlayer {
        GKLocalPlayer.local
    }
    

    func toggleReady() {
        service.setReady(gamePhase: .voting)
    }
    
    
    func submissions(for phrase: String) -> [ImageSubmission] {
        let localID = GKLocalPlayer.local.gamePlayerID
        var result: [ImageSubmission] = []
        
        for gamePlayer in service.gamePlayers {
            if let currentRoundSubmission = gamePlayer.submissions.first(where: { $0.round == service.currentRound }) {
                if currentRoundSubmission.playerID != localID {
                    result.append(currentRoundSubmission.imageSubmission)
                }
            }
        }
        return result
    }
    
    func finishVoting() {
        print("🗯🏻 Votação terminada - computando votos")
    }
    
    func cleanAndStoreSubmissions() {
        service.cleanAndStorePlayerSubmissions()
    }
    
    func resetAllPlayersReady() {
        service.resetReadyForAllPlayers(gamePhase: .voting)
    }

    private func startCountdown(until target: Date) {
        timer?.invalidate()
        timer = nil
        hasProcessedTimeRunOut = false
        updateRemaining(target: target)
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateRemaining(target: target)
        }
    }
    
    private func updateRemaining(target: Date) {
        let remainingSecondsDouble = target.timeIntervalSinceNow
        
        timeRemaining = max(0, Int(ceil(remainingSecondsDouble)))
        remainingTimeDouble = max(0.0, remainingSecondsDouble)
        
        if timeRemaining == 0 && !hasProcessedTimeRunOut {
            timer?.invalidate()
            hasProcessedTimeRunOut = true
        }
    }
    
    func voteImage(imageSubmission: ImageSubmission) {
        print("votando")
        service.submitVote(imageSubmission: imageSubmission)
    }
    
    func nextRound() {
        service.goToNextRound()
    }
    
    var isGameOver: Bool {
      //  isPhraseArrayEmpty() && isVotingSessionDone
        return false
    }
    
    var isVotingSessionDone: Bool  {
        service.expectedPlayersCount == service.votes.values.count
    }
    
    func isPhraseArrayEmpty() -> Bool {
        if service.phrases.isEmpty {
            return true
        } else {
            return false
        }
    }
}
