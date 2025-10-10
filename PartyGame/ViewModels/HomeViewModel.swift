//
//  HomeViewModel.swift
//  PartyGame
//
//  Created by Fernando Sulzbach on 09/09/25.
//

import SwiftUI
import GameKit

@Observable
class HomeViewModel {
    
    var isAuthenticated: Bool { service.isAuthenticated }
    var isInMatch: Bool { service.isInMatch }
    
    private var pendingInvite: GKInvite?
    private var pendingPlayersToInvite: [GKPlayer]?
    
    private let service = GameCenterService.shared
    
    init() {
        // Remove a atribuição direta, agora as propriedades são computed properties.
        // A observação é automática via @Observable.
    }
        
    func startSinglePlayerGame() {
        service.startMatchmaking(minPlayers: 1, maxPlayers: 1, singlePlayerMode: true)
    }

    func startMultiplayerGame(minPlayers: Int = 2, maxPlayers: Int = 8) {
        service.startMatchmaking(minPlayers: minPlayers, maxPlayers: maxPlayers, singlePlayerMode: false)
    }
    
    func sendMessage(_ text: String) {
        service.sendMessage(text)
    }
    
    func processPendingInvite() {
        service.processPendingInvite()
    }
}
