//
//  DebuggingView.swift
//  Pickture
//
//  Created by Giulia Stefainski on 29/09/25.
//

import SwiftUI

struct DebuggingView: View {
    var viewModel: VotingViewModel = VotingViewModel()
    
    var body: some View {
        
//        @State var showAlert = false
        Text("Votes: \(viewModel.service.votes)")
        Text("-------")
        ForEach(viewModel.service.playerSubmissions, id: \.playerID) { player in
            Text("\(player.playerID) - \(player.votes)")
        }
    }
}

#Preview {
    DebuggingView()
}
