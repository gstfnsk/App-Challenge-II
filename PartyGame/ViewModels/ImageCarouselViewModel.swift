//
//  HomeViewModel.swift
//  PartyGame
//
//  Created by Fernando Sulzbach on 09/09/25.
//
import SwiftUI
import GameKit

class ImageCarouselViewModel: ObservableObject {
        
    private let service: GameCenterService
    
    init(service: GameCenterService = GameCenterService()) {
        self.service = service
    }
}
