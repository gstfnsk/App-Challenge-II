//
//  Untitled.swift
//  PartyGame
//
//  Created by Fernando Sulzbach on 11/09/25.
//
import SwiftUI

struct ImageStackView: View {
    @ObservedObject var viewModel = ImageStackViewModel()
    
    @State var submittedPhrase = ""
    
    @State var imageSubmissions: [ImageSubmission]
    
    @State private var timer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()
    @State private var isDone: Bool = false

    var body: some View {
        HStack {
            VStack {
                
                Text(submittedPhrase)
                    .font(.headline)
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
                
                ImageStackComponent(cards: $imageSubmissions, isDone: $isDone, timer: timer)
            }
            .onChange(of: isDone) {
                print("Done!")
            }
        }
        .navigationBarBackButtonHidden(true)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 32)
        .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))
//        .onChange(of: isDone) {
//            viewModel.resetAllPlayersReady()
//        }
        .navigationDestination(isPresented: $isDone) {
            VotingView(phrase: submittedPhrase, imageSubmissions: imageSubmissions)
        }
    }
}

//#Preview {
//    ImageStackView()
//}
