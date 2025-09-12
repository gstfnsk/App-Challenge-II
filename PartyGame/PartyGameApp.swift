//
//  PartyGameApp.swift
//  PartyGame
//
//  Created by Giulia Stefainski on 03/09/25.
//

import SwiftUI

@main
struct PicktureApp: App {
    @StateObject private var gameCenter = GameCenterService()

    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: HomeViewModel(service: gameCenter))
        }
    }
}
