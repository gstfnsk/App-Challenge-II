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
        Text("Votes: \(viewModel.service.votes)")
    }
}

#Preview {
    DebuggingView()
}
