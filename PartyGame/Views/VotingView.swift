////
////  VotingView.swift
////  PartyGame
////
////  Created by Giulia Stefainski on 09/09/25.
////
//
//import SwiftUI
//import UIKit
//import PinterestLikeGrid
//
//struct VotingView: View {
//    @State var selectedImage: UUID?
//    var viewModel: VotingViewModel = VotingViewModel(
//        service: GameCenterService()
//    )
//    let columns = [
//        GridItem(.flexible()),
//        GridItem(.flexible()),
//    ]
//    @State var imageSubmissions: [ImageSubmission] = [
//        ImageSubmission(
//            image: UIImage(named: "img-placeholder16x9")!.jpegData(
//                compressionQuality: 1.0
//            )!,
//            submissionTime: Date()
//        ),
//        ImageSubmission(
//            image: UIImage(named: "img-placeholder1x1")!.jpegData(
//                compressionQuality: 1.0
//            )!,
//            submissionTime: Date()
//        ),
//        ImageSubmission(
//            image: UIImage(named: "img-placeholder9x16")!.jpegData(
//                compressionQuality: 1.0
//            )!,
//            submissionTime: Date()
//        ),
//        ImageSubmission(
//            image: UIImage(named: "img-placeholder3x4")!.jpegData(
//                compressionQuality: 1.0
//            )!,
//            submissionTime: Date()
//        ),
//    ]
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading) {
//                Text("vote for the best")
//                Spacer()
//                Text("a moment in nature")
//                PinterestLikeGrid($imageSubmissions, columns: 2, spacing: 16) { photo, index in
//                    Button {
//                        viewModel.voteImage(id: photo.id) // depois passar UUID da imagem
//                        selectedImage = photo.id
//                    } label: {
//                        if let data = photo.image, let uiImage = UIImage(data: data)
//                        {
//                            Image(uiImage: uiImage)
//                                .resizable()
//                                .scaledToFit()
//                                .cornerRadius(28)
//                                .overlay(RoundedRectangle(cornerRadius: 28)
//                                    .stroke(Color.white, lineWidth: 4))
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 28)
//                                        .stroke(
//                                            selectedImage == photo.id
//                                            ? Color.green : Color.white,
//                                            lineWidth: 4
//                                        )
//                                )
//                        } else {
//                            Rectangle()
//                                .fill(Color.gray.opacity(0.3))
//                                .overlay(Text("No Img"))
//                                .cornerRadius(28)
//                        }
//                    }
//                }
//            }
//            if let selectedImage {
//                Text("you voted \(selectedImage)")
//            }
//            ButtonView(title: "confirm vote")
//        }
//    }
//}
//
////#Preview {
////    VotingView()
////}
