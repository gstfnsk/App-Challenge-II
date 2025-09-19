//
//  PartyGameApp.swift
//  PartyGame
//
//  Created by Giulia Stefainski on 03/09/25.
//

import SwiftUI

@main
struct PicktureApp: App {
    @StateObject var service = GameCenterService.shared

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
