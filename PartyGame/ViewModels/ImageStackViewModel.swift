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
        service.playerSubmissions
            .filter { $0.phrase == phrase }
            .map { $0.imageSubmission }
    }
}
