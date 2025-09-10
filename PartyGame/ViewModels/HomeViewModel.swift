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
    
    private var pendingInvite: GKInvite?
    private var pendingPlayersToInvite: [GKPlayer]?
    
    private let service: GameCenterService
    
    init(service: GameCenterService = GameCenterService()) {
        self.service = service
        
        service.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .assign(to: &$isAuthenticated)
    }
        
    func startMatchmaking() {
        service.startMatchmaking()
    }
    
    func sendMessage(_ text: String) {
        service.sendMessage(text)
    }
    
    func processPendingInvite() {
        service.processPendingInvite()
    }
}
