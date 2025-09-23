//
//  VotingView.swift
//  PartyGame
//
//  Created by Giulia Stefainski on 09/09/25.
//

import SwiftUI
import UIKit
import PinterestLikeGrid

struct VotingView: View {
    @State var phrase: String
    @State var selectedImage: UUID?
    @State var goToNextRound: Bool = false
    var viewModel: VotingViewModel = VotingViewModel()
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    @State var imageSubmissions: [ImageSubmission] = []
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("vote for the best")
                Spacer()
                Text(phrase)
                PinterestLikeGrid($imageSubmissions, columns: 2, spacing: 16) { photo, index in
                    Button {
                        viewModel.voteImage(id: photo.id)
                        selectedImage = photo.id
                    } label: {
                        if let data = photo.image, let uiImage = UIImage(data: data)
                        {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(28)
                                .overlay(RoundedRectangle(cornerRadius: 28)
                                    .stroke(Color.white, lineWidth: 4))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 28)
                                        .stroke(
                                            selectedImage == photo.id
                                            ? Color.green : Color.white,
                                            lineWidth: 4
                                        )
                                )
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(Text("No Img"))
                                .cornerRadius(28)
                        }
                    }
                }
            }
            if let selectedImage {
            ButtonView(image: "iconVoteButton", title: "confirm vote", titleDone: "vote confirmed", action: {
                    viewModel.submitVote()
                    goToNextRound = true
            }, state: .enabled)
            } else {
                ButtonView(image: "iconVoteButton", title: "confirm vote", titleDone: "vote confirmed", action: {
                    viewModel.submitVote()
                    goToNextRound = true
                }, state: .inactive)
            }
        }
        .onAppear {
            // Filtra as imagens submetidas para a frase atual
            imageSubmissions = viewModel.submissions(for: phrase)
        }
        .navigationBarBackButtonHidden(true)
    }
}
