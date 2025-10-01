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
final class VotingViewModel: ObservableObject {
    let service = GameCenterService.shared
    private var cancellables = Set<AnyCancellable>()

    private var timer: Timer?
    var hasProcessedTimeRunOut: Bool = false
    var remainingTimeDouble: Double = 30.0
    var timeRemaining: Int = 30
    
    var players: [GKPlayer] = []
    var readyMap: [String: Bool] = [:]
    
    var allReady: Bool {
        guard !players.isEmpty else { return false }
        for p in players {
            if readyMap[p.gamePlayerID] != true { return false }
        }
        return true
    }
    
    init() {
        self.players = service.gamePlayers.map { $0.player }
        
        service.$readyMap
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] newMap in
                        self?.readyMap = newMap
                    }
                    .store(in: &cancellables)
        
         service.$timerStart
            .removeDuplicates()
               .compactMap { $0 }
               .receive(on: DispatchQueue.main)
               .sink { [weak self] target in
                   self?.startCountdown(until: target)
               }
               .store(in: &cancellables)
        
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
        cancellables.forEach { $0.cancel() }
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
    
    


    // Todas as submissões para a frase atual
    func submissions(for phrase: String) -> [ImageSubmission] {
        service.playerSubmissions
            .filter { $0.phrase == phrase }
            .map { $0.imageSubmission }
    }
    
    func finishVoting() {
        print("🗯🏻 Votação terminada - computando votos")
    }
    
    

    func cleanAndStoreSubmissions() {
        service.cleanAndStorePlayerSubmissions()
    }
    
    func resetAllPlayersReady() {
        service.resetReadyForAllPlayers()
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
    
    func startPhase() {
        print("🚀 Starting phase - resetting all states")
        hasProcessedTimeRunOut = false
        
        service.schedulePhaseStart(delay: 30)
    }
    

    func voteImage(id: UUID) {
        let playerID = GKLocalPlayer.local.gamePlayerID
        print("votando")
        service.submitVote(id: id, player: playerID)
    }
    
    func nextRound() {
        service.goToNextRound()
    }
    
    var isGameOver: Bool {
//        service.isPhrasesEmpty && isVotingSessionDone
        return false
    }
    
    var isVotingSessionDone: Bool  {
        service.expectedPlayersCount == service.votes.values.count
    }
}
