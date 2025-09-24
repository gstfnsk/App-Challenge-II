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
    @State var imageSubmissions: [ImageSubmission] = [
        ImageSubmission(
            playerID: "", image: UIImage(named: "img-placeholder16x9")!.jpegData(compressionQuality: 1.0)!,
            submissionTime: Date()
        ),
        ImageSubmission(
            playerID: "", image: UIImage(named: "img-placeholder1x1")!.jpegData(compressionQuality: 1.0)!,
            submissionTime: Date()
        ),
        ImageSubmission(
            playerID: "", image: UIImage(named: "img-placeholder9x16")!.jpegData(compressionQuality: 1.0)!,
            submissionTime: Date()
        )
    ]
    
    var body: some View {
        ZStack {
            // Fundo
            Image("img-texture5")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            // Topo fixo
            VStack {
                VStack(alignment: .leading) {
                    Text("round 1")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(.lilac)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Text("vote for the best")
                            .font(.custom("DynaPuff-Medium", size: 28))
                            .foregroundStyle(.ice
                                .shadow(.inner(color: .lilac, radius: 2, y: 3)))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        TimerComponent(duration: 30.0)
                    }
                    
                    ProgressBarComponent(duration: 30.0)
                }
                .padding(.horizontal)
                Spacer()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("the phrase is:")
                            .foregroundColor(.ice)
                            .font(.headline)
                        
                        Text("\"\(phrase)\"").font(.custom("DynaPuff-Medium", size: 22))
                            .foregroundStyle(.ice)
                        
                        PinterestLikeGrid($imageSubmissions, columns: 2, spacing: 16) { photo, index in
                            Button {
                                selectedImage = photo.id
                            } label: {
                                if let data = photo.image, let uiImage = UIImage(data: data) {
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
                                                    ? Color.lightGreen : Color.white,
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
                        .frame(maxWidth: .infinity)
                        
                        if let selectedImage {
                            ButtonView(image: "iconVoteButton", title: "confirm vote", titleDone: "vote confirmed", action: {
                                goToNextRound = true
                            }, state: .enabled)
                        } else {
                            ButtonView(image: "iconVoteButton", title: "confirm vote", titleDone: "vote confirmed", action: {
                                goToNextRound = true
                            }, state: .inactive)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
            }
            //            .onAppear {
            //                imageSubmissions = viewModel.submissions(for: phrase)
            //            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
}
#Preview {
    VotingView(phrase: "teste")
}