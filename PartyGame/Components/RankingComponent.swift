//
//  ChartData.swift
//  Pickture
//
//  Created by Fernando Sulzbach on 17/09/25.
//


//
//  BarChartExampleView.swift
//  PartyGame
//
//  Created by Fernando Sulzbach on 17/09/25.
//

import SwiftUI
import Charts
import GameKit

struct RankingComponent: View {
    
    let players: [Player]
    
    var body: some View {
        Chart(players.sorted(by: { $0.votes > $1.votes })) { player in
            BarMark(x: .value("Votes", player.votes),
                    y: .value("Player Names", player.player.displayName))
            .foregroundStyle(by: .value("Player Names", player.player.displayName))
            .annotation(position: .trailing) {
                Text(String(player.votes))
                    .font(Font.custom("DynaPuff-Regular", size: 16))
                    .foregroundColor(.darkerPurple)
            }
        }
        .chartLegend(.hidden)
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let name = value.as(String.self) {
                        Text(name)
                            .font(Font.custom("DynaPuff-Regular", size: 16))
                            .foregroundColor(.darkerPurple)
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        //.padding()
    }
}

#Preview {
   // RankingComponent()
}
