//
//  ImageVotingList.swift
//  PartyGame
//
//  Created by Fernando Sulzbach on 09/09/25.
//

//import SwiftUI
//
//struct ImageVotingList: View {
//    
//    var imageSubmissions: [ImageSubmission] = [
//        ImageSubmission(playerName: "playerOne", image: Image( "img-placeholder16x9")),
//        ImageSubmission(playerName: "playerTwo", image: Image( "img-placeholder1x1")),
//        ImageSubmission(playerName: "playerTwo", image: Image( "img-placeholder9x16"))
//    ]
//    
//    var body: some View {
//        
//        TabView {
//            ForEach(imageSubmissions) { submission in
//                    submission.image
//                        .resizable()
//                        .scaledToFill()
//                        .frame(width: 300, height: 400)
//                        .background(Color.red)
//                        
//            }
//            
//            
//        }
//        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
//        .frame(maxWidth: .infinity, maxHeight: 500)
//        Spacer()
//    }
//}
//
//#Preview {
//    ImageVotingList()
//}
