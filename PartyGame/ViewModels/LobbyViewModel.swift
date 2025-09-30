//
//  LobbyViewModel.swift
//  PartyGame
//
//  Created by Rafael Toneto on 10/09/25.
//

import Foundation
import SwiftUI
import Combine
import GameKit

final class LobbyViewModel: ObservableObject {
    
    @Published var players: [GKPlayer] = []
    @Published var messages: [String] = []
    @Published var typedMessage: String = ""
    
    @Published var isInMatch: Bool = false
    @Published var readyMap: [String: Bool] = [:]
    
    @Published var isSliderComplete: Bool = false
    
    private let service = GameCenterService.shared
    
    init() {
        
        self.players = service.gamePlayers.map { $0.player }
        
        //service.$gamePlayers
        //    .receive(on: DispatchQueue.main)
        //    .assign(to: &$players)
        
        service.$messages
            .receive(on: DispatchQueue.main)
            .assign(to: &$messages)
        
        service.$isInMatch
            .receive(on: DispatchQueue.main)
            .assign(to: &$isInMatch)
        
        service.$readyMap
            .receive(on: DispatchQueue.main)
            .assign(to: &$readyMap)
    }
    
    func sendMessage() {
        let text = typedMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        service.sendMessage(text)
        typedMessage = ""
    }
    
    func leaveLobby() {
        service.leaveMatch()
    }
    
    func electLeader() {
        service.electPhraseLeader()
    }
    
    func toggleReady() {
        service.toggleReady()
    }
    
    func markSliderComplete() {
        isSliderComplete = true
        toggleReady()
    }
    
    func markSliderIncomplete() {
        isSliderComplete = false
    }
    
    var localPlayerID: String { GKLocalPlayer.local.gamePlayerID }
    var isLocalReady: Bool { readyMap[localPlayerID] ?? false }
    var allReady: Bool {
        guard !players.isEmpty else { return false }
        for p in players {
            if readyMap[p.gamePlayerID] != true { return false }
        }
        return true
    }
    
    func resetAllPlayersReady() {
        service.resetReadyForAllPlayers()
    }
}
