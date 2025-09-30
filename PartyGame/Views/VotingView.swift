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
                    
                    HStack {
                        Text("vote for the best")
                            .font(.custom("DynaPuff-Medium", size: 28))
                            .foregroundStyle(.ice
                                .shadow(.inner(color: .lilac, radius: 2, y: 3)))
                        TimerComponent(remainingTime: 30, duration: 30.0)
                    }
                    
                    ProgressBarComponent(progress: .constant(30.0))
                }
                .padding(.top, 59)
                .padding(.horizontal)
                Spacer()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack (spacing: 16){
                            Text("the phrase is:")
                                .foregroundColor(.ice)
                                .font(.headline)
                            
                            Text("\"\(phrase)\"").font(.custom("DynaPuff-Medium", size: 22))
                                .foregroundStyle(.ice)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 26).foregroundStyle(.lighterPurple))
                        .padding([.leading, .trailing, .top], 16)
                        VStack {
                            PinterestLikeGrid($imageSubmissions, columns: 2, spacing: 16) { photo, index in
                                Button {
                                    selectedImage = photo.id
                                } label: {
                                    // Text(photo.id.uuidString)
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
                                                        ? Color.lightGreen : Color.lilac,
                                                        lineWidth: 4
                                                    )
                                            )
                                            .overlay(alignment: .topTrailing) {
                                                if selectedImage == photo.id {
                                                    Image("img-check")
                                                        .resizable()
                                                        .frame(width: 40, height: 40)
                                                        .offset(x: 10, y: -10)
                                                }
                                            }
                                    } else {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .overlay(Text("No Img"))
                                            .cornerRadius(28)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding([.leading, .trailing, .bottom], 16)
                        .padding(.top, 8)
                    }
                    .background(GradientBackground())
                    .padding()
                    .frame(maxWidth: .infinity)
                    //                    .padding(.bottom, 14)
                    Spacer().frame(height: 100)
                }
            }
            
            //            .onAppear {
            //                imageSubmissions = viewModel.submissions(for: phrase)
            //            }
            .navigationBarBackButtonHidden(true)
            
            VStack() {
                Spacer()
                if let selectedImage {
                    ButtonView(image: "iconVoteButton", title: "confirm vote", titleDone: "vote confirmed", action: {
                        print("UUID da imagem:", selectedImage)
//                        viewModel.cleanAndStoreSubmissions()
                        viewModel.toggleReady()
                    }, state: .enabled)
                } else {
                    ButtonView(image: "iconVoteButton", title: "confirm vote", titleDone: "vote confirmed", action: {
                    }, state: .inactive)
                }
                
            }
            .padding(.bottom, 34)
            .padding(.horizontal, 16)
        }
        
        .onAppear {
            imageSubmissions = viewModel.submissions(for: phrase)
        }
        .onChange(of: viewModel.allReady) {
            if !viewModel.players.isEmpty {
                    if let selectedImage {
                        viewModel.voteImage(id: selectedImage)
                    }
                    goToNextRound = true
                    viewModel.nextRound()
            }
            viewModel.resetAllPlayersReady()
        }
        .navigationDestination(isPresented: $goToNextRound) {
            DebuggingView()
        }
        .navigationBarBackButtonHidden(true)
        .background(Color.darkerPurple)
    }
    
    struct GradientBackground: View {
        let gradientBackground = LinearGradient(
            gradient: Gradient(colors: [.lilac.opacity(0.5), .lighterPink.opacity(0.5)]),
            startPoint: .top,
            endPoint: .bottom)
        
        var body: some View {
            RoundedRectangle(cornerRadius: 32)
                .fill(gradientBackground
                    .shadow(.inner(color: Color.lilac, radius: 2, x: 0, y: 5)))
        }
        
    }
    
}
#Preview {
    VotingView(phrase: "teste")
}
