//
//  PartyGameApp.swift
//  PartyGame
//
//  Created by Giulia Stefainski on 03/09/25.
//

import SwiftUI

@main
struct PicktureApp: App {
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                HomeView()
            } else {
                OnboardingView()
            }
        }
    }
}
