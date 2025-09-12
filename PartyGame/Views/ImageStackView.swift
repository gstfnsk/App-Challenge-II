//
//  Untitled.swift
//  PartyGame
//
//  Created by Fernando Sulzbach on 11/09/25.
//
import SwiftUI

struct ImageStackView: View {
    
    @State var submittedPhrase = "Your submitted phrase must go here and your submitted phrase must go here"
    @State var imageSubmissions: [ImageSubmission] = [
        ImageSubmission(image: UIImage(named: "img-placeholder16x9")?.pngData(), submissionTime: Date()),
        ImageSubmission(image: UIImage(named: "img-placeholder4x3")?.pngData(), submissionTime: Date()),
        ImageSubmission(image: UIImage(named: "img-placeholder9x16")?.pngData(), submissionTime: Date()),
        ImageSubmission(image: UIImage(named: "img-placeholder16x9")?.pngData(), submissionTime: Date()),
        ImageSubmission(image: UIImage(named: "img-placeholder4x3")?.pngData(), submissionTime: Date()),
        ImageSubmission(image: UIImage(named: "img-placeholder9x16")?.pngData(), submissionTime: Date())
    ]
    
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 32)
        .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    ImageStackView()
}
