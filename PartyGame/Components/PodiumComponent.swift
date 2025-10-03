//
//  PodiumComponent.swift
//  Pickture
//
//  Created by Fernando Sulzbach on 02/10/25.
//
import SwiftUI

struct PodiumComponent: View {
    
    var body: some View {
        
        HStack(alignment: .center, spacing: 16) {
                CircleComponent(
                    isWinner: false,
                    name: "Bob",
                    points: 11,
                    secondImage: "img-second"
                )
                // .offset(y: 71)

                CircleComponent(
                    isWinner: true,
                    name: "Bob",
                    points: 11,
                    secondImage: "img-winner"
                )
            
                CircleComponent(
                    isWinner: false,
                    name: "Bob",
                    points: 11,
                    secondImage: "img-third"
                )
               // .offset(y: 71)
        }
        
    }
}

#Preview {
    
    PodiumComponent()
    
}


