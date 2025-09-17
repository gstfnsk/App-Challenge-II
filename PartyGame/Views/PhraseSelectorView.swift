//
//  PhraseSelectorView.swift
//  PartyGame
//
//  Created by Lorenzo Fortes on 09/09/25.
//

import SwiftUI

struct PhraseSelectorView: View {
    
    @State var selectedPhrase: Phrase = .init(text: "write your own phrase here", category: .action)
    @State var displayedPhrases: [Phrase] = []
    
    let columns = [GridItem(.flexible())]
    
    var body: some View {
        ZStack{
            Image("texture")
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0)
                .edgesIgnoringSafeArea(.all)
                
            VStack (spacing: 101) {
                Text("Component")
                    .frame(alignment: .top)
                    .font(.system(size: 64, weight: .bold, design: .default))
                VStack(spacing: 64){
                    VStack(spacing: 16){
                        TextField(
                            "write your own phrase here",
                            text: $selectedPhrase.text)
                        .foregroundStyle(.lilac)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity, minHeight: 52, maxHeight: 52, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 26)
                            .fill(Color.lighterPurple.shadow(.inner(color: .darkerPurple, radius: 2, y: 3))))
                    
                        VStack(spacing: 16){
                            HStack(spacing: 63){
                                Text("or choose one of ours:")
                                    .foregroundStyle(.ice)
                                    .fontWeight(.semibold)
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                Button{
                                    displayedPhrases = Array(Phrases.all.shuffled().prefix(3))
                                }label: {
                                    Image("Dice")
                                        .background(Circle()
                                            .frame(width: 35, height: 36)
                                            .foregroundStyle(Color.lilac))
                                            
                                }
                                       
                            }
                            LazyVGrid(columns: columns, spacing: 8){
                                ForEach(displayedPhrases, id: \.self) { phrase in
                                    PhraseComponent(phrase: phrase,
                                                    isSelected: phrase == selectedPhrase,
                                                    onSelect: {
                                        selectedPhrase = phrase
                                    })
                                }
                                
                            }
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal)
                        .background(RoundedRectangle(cornerRadius: 26).fill(Color.lighterPurple))
                        
                    }
                    .padding(.horizontal)
                    .padding(.vertical)
                    .background(GradientBackground()
                    .opacity(0.5))
                    
                }
                .padding(.horizontal)
                Button {
                    print("Submitted phrase: \(selectedPhrase)")
                }label: {
                    Text("Component")
                }
                .foregroundStyle(.primary)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.tertiary)
                        .frame(width: 356, height: 42)
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .onAppear() {
                    displayedPhrases = Array(Phrases.all.shuffled().prefix(3))
                }
            }
        }
        .background(Color.darkerPurple)
    }
}

struct GradientBackground: View {
    let gradientBackground = LinearGradient(
        gradient: Gradient(colors: [.lilac, .lighterPink]),
        startPoint: .top,
        endPoint: .bottom)

    var body: some View {
        RoundedRectangle(cornerRadius: 32)
            .fill(gradientBackground
                .shadow(.inner(color: Color.white, radius: 2, x: 0, y: 3)))
    }
}
#Preview {
    PhraseSelectorView()
}
