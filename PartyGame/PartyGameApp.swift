//
//  PartyGameApp.swift
//  PartyGame
//
//  Created by Giulia Stefainski on 03/09/25.
//

import SwiftUI

@main
struct PicktureApp: App {
    
    init() {
        UINavigationBar.appearance().titleTextAttributes = [
            .font: UIFont(name: "Dynapuff-Regular", size: 17) ?? UIFont.systemFont(ofSize: 17)
        ]
    }
    
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
