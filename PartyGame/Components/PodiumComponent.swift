//
//  PodiumComponent.swift
//  Pickture
//
//  Created by Fernando Sulzbach on 02/10/25.
//
import SwiftUI

struct PodiumComponent: View {
    var topPlayers: [PlayerSnapshot]
    var body: some View {
        
        HStack(alignment: .center, spacing: 16) {
                CircleComponent(
                    isWinner: false,
                    name: topPlayers[1].name,
                    points: topPlayers[1].votes,
                    secondImage: "img-second"
                )
                // .offset(y: 71)

                CircleComponent(
                    isWinner: true,
                    name: topPlayers[0].name,
                    points: topPlayers[0].votes,
                    secondImage: "img-winner"
                )
            
                CircleComponent(
                    isWinner: false,
                    name: topPlayers[2].name,
                    points: topPlayers[2].votes,
                    secondImage: "img-third"
                )
               // .offset(y: 71)
        }
        
    }
}

#Preview {
//    PodiumComponent()
}


