//
//  VotingView.swift
//  PartyGame
//
//  Created by Giulia Stefainski on 09/09/25.
//

import SwiftUI
import UIKit

struct VotingView: View {
    @State var selectedImage: UUID?
    @Bindable var viewModel: VotingViewModel
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    let imageSubmissions: [ImageSubmission] = [
        ImageSubmission(
            image: UIImage(named: "img-placeholder16x9")!.jpegData(compressionQuality: 1.0)!,
            submissionTime: Date()
        ),
        ImageSubmission(
            image: UIImage(named: "img-placeholder1x1")!.jpegData(compressionQuality: 1.0)!,
            submissionTime: Date()
        ),
        ImageSubmission(
            image: UIImage(named: "img-placeholder9x16")!.jpegData(compressionQuality: 1.0)!,
            submissionTime: Date()
        )
    ]
    var body: some View {
        ScrollView {
            VStack(alignment: .center) {
                Text("Vote!")
                Text("Vote the image for the phrase \"Example\" ")
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(imageSubmissions) { photo in
                        Button {
                            viewModel.voteImage(id: photo.id) // depois passar UUID da imagem
                            selectedImage = photo.id
                        } label: {
                            //                            if let image = viewModel.loadImage(id: photo.id) {
                            if let data = photo.image, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .scaledToFit()
                                    .clipped()
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(selectedImage == photo.id ? Color.blue : Color.clear, lineWidth: 4)
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
            if let selectedImage {
                Text("You voted \(selectedImage)")
            }
            ButtonView(title: "Confirm")
        }
    }
}

//#Preview {
//    VotingView()
//}
