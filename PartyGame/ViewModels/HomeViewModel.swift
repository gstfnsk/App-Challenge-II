//
//  HomeViewModel.swift
//  PartyGame
//
//  Created by Fernando Sulzbach on 09/09/25.
//

import SwiftUI
import GameKit

class HomeViewModel: ObservableObject {
    
    @Published var isAuthenticated: Bool = false
    @Published var isInMatch: Bool = false
    
    private var pendingInvite: GKInvite?
    private var pendingPlayersToInvite: [GKPlayer]?
    
    private let service = GameCenterService.shared
    
    init() {
        
        service.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .assign(to: &$isAuthenticated)
        
        service.$isInMatch
            .receive(on: DispatchQueue.main)
            .assign(to: &$isInMatch)
    }
        
    func startSinglePlayerGame() {
        service.startMatchmaking(minPlayers: 1, maxPlayers: 1, singlePlayerMode: true)
    }

    func startMultiplayerGame(minPlayers: Int = 2, maxPlayers: Int = 4) {
        service.startMatchmaking(minPlayers: minPlayers, maxPlayers: maxPlayers, singlePlayerMode: false)
    }
    
    func sendMessage(_ text: String) {
        service.sendMessage(text)
    }
    
    func processPendingInvite() {
        service.processPendingInvite()
    }
}
