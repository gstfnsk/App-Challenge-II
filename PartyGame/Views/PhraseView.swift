//
//  PhraseSelectorView.swift
//  PartyGame
//
//  Created by Lorenzo Fortes on 09/09/25.
//

import SwiftUI


struct PhraseView: View {
    
    var viewModel = PhraseViewModel()
    @State var selectedPhrase: Phrase = .init(text: "write your own phrase here", category: .action)
    @State var displayedPhrases: [Phrase] = []
    @State var nextScreen: Bool = false
    
    let columns = [GridItem(.flexible())]
    
    private var button: some View { ButtonHighFidelityView(image: "img-pencilSymbol", title: "confirmPhrase", action:{
        print("Submitted phrase: \(selectedPhrase)")
        viewModel.submitPhrase(phrase: selectedPhrase.text)
        if viewModel.haveAllPlayersSubmitted {
            nextScreen = true
        }
    }, enabled: true)}
    
    var body: some View {
        ZStack{
            Image("img-textureI")
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0)
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 85){
                VStack(spacing: 24){
                    VStack(spacing: 5){
                        Text("round1")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(.lilac)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 34){
                            Text("submit a phrase")
                                .font(.custom("DynaPuff-Medium", size: 28))
                                .foregroundStyle(.ice
                                    .shadow(.inner(color: .lilac, radius: 2, y: 3)))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            TimerComponent(duration: 30.0)
                        }
                    }
                    ProgressBarComponent(duration: 30.0)
                }
                .padding(.horizontal)
                VStack (spacing: 177){
                    VStack(spacing: 64){
                        VStack(spacing: 16){
                            VStack(spacing: 16){
                                TextField(
                                    "write your own phrase here",
                                    text: $selectedPhrase.text)
                                .foregroundStyle(.lilac)
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
                            .background(GradientBackground())
                            
                        }
                        .onAppear() {
                            displayedPhrases = Array(Phrases.all.shuffled().prefix(3))
                        }

                    }
                    button
                }
                .padding(.horizontal)
            }
        }
        .background(Color.darkerPurple)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $nextScreen) {
            ImageSelectionView()
        }
        .onChange(of: viewModel.haveAllPlayersSubmitted) {
            nextScreen = true
        }
    }
    
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


#Preview {
    PhraseView()
}
