//
//  VotingView.swift
//  PartyGame
//
//  Created by Giulia Stefainski on 09/09/25.
//

import SwiftUI
import SwiftData

struct VotingView: View {
    @State var selectedImage: String = ""
    @Bindable var viewModel: VotingViewModel
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    let photos = [
        "photo1", "photo2", "photo3", "photo4",
        "photo5", "photo6", "photo7", "photo8",
        "photo9", "photo10"
    ]
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                Text("Vote!")
                Text("Vote the image for the phrase \"Example\" ")
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(photos, id: \.self) { photo in
                        Button {
                            viewModel.voteImage(image: photo)
                            selectedImage = photo
                        } label: {
                            if let image = viewModel.loadImage(name: photo) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .clipped()
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(selectedImage == photo ? Color.blue : Color.clear, lineWidth: 4)
                                    )
                            } else {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .overlay(Text("No Img"))
                                    .cornerRadius(8)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }.padding(8)
            }
            if selectedImage != "" {
                Text("You voted \(selectedImage)")
            }
            ButtonView(title: "Confirm")
        }
    }
}

//#Preview {
//    VotingView()
//}
