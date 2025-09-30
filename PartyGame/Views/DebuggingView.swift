//
//  DebuggingView.swift
//  Pickture
//
//  Created by Giulia Stefainski on 29/09/25.
//

import SwiftUI

struct DebuggingView: View {
    @State private var displayVotes = false
    var viewModel = VotingViewModel()

    var body: some View {
        VStack {
            if displayVotes {
                Text("Votes: \(viewModel.service.votes)")
            }
            
            Text("-------")
            ForEach(viewModel.service.playerSubmissions, id: \.playerID) { player in
                Text("\(player.playerID) - \(player.votes)")
            }
        }
        .onChange(of: viewModel.isVotingSessionDone) { _ in
            displayVotes = viewModel.isVotingSessionDone
        }
    }
}

#Preview {
    DebuggingView()
}
