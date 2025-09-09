//
//  HomeViewModel.swift
//  PartyGame
//
//  Created by Fernando Sulzbach on 09/09/25.
//
import SwiftUI

class HomeViewModel: ObservableObject {
    
    @Published var messages: [String] = []
    @Published var isAuthenticated: Bool = false
    
    private let service: GameCenterService
    
    init(service: GameCenterService = GameCenterService()) {
        self.service = service
        
        service.$messages
            .receive(on: DispatchQueue.main)
            .assign(to: &$messages)
        
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
