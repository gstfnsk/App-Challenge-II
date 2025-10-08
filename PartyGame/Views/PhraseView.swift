//
//  PhraseSelectorView.swift
//  PartyGame
//
//  Created by Lorenzo Fortes on 09/09/25.
//

import SwiftUI


struct PhraseView: View {

    var viewModel = PhraseViewModel()
    @State var selectedPhrase: Phrase? = nil
    @State var displayedPhrases: [Phrase] = []
    @State var nextScreen: Bool = false
    
    var isButtonInactive: Bool {
        guard let phrase = selectedPhrase else {
            return true
        }
        return phrase.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    let columns = [GridItem(.flexible())]
    
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
                        Text("round \(viewModel.service.currentRound)")

                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(.lilac)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 34){
                            Text("submit a phrase")
                                .font(.custom("DynaPuff-Medium", size: 28))
                                .foregroundStyle(.ice
                                    .shadow(.inner(color: .lilac, radius: 2, y: 3)))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            TimerComponent(remainingTime: Int(30.0), duration: 30.0)
                        }
                    }
                    ProgressBarComponent(progress: .constant(1.0))
                }
                .padding(.horizontal)
                
                VStack (spacing: 177){
                    VStack(spacing: 16){
                        TextField(
                            "write your own phrase here",
                            text: Binding(
                                get: { selectedPhrase?.text ?? "" },
                                set: { newValue in
                                    if var phrase = selectedPhrase {
                                        phrase.text = newValue
                                        selectedPhrase = phrase
                                    } else {
                                        selectedPhrase = Phrase(text: newValue, category: .action)
                                    }
                                }
                            )
                        )
                        .foregroundStyle(.lilac)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity, minHeight: 52, maxHeight: 52, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 26)
                            .fill(Color.lighterPurple.shadow(.inner(color: .darkerPurple, radius: 2, y: 3))))
                        
                        VStack(spacing: 16){
                            HStack(spacing: 63){
                                Text("or choose one of ours:")
                                    .lineLimit(1)
                                    .foregroundStyle(.ice)
                                    .fontWeight(.semibold)
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    .frame(maxWidth: .infinity)
                                DiceButton{
                                    viewModel.dicePressed()
                                    displayedPhrases = viewModel.selectablePhrases
                                }
                            }
                            
                            LazyVGrid(columns: columns, spacing: 8){
                                ForEach(displayedPhrases, id: \.self) { phrase in
                                    PhraseComponent(
                                        phrase: phrase,
                                        isSelected: phrase == selectedPhrase,
                                        onSelect: {
                                            selectedPhrase = phrase
                                        },
                                        isEnabled: !viewModel.isSelectionDisabled
                                    )
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
                    .frame(maxHeight: 350, alignment: .top)
                    .onAppear() {
                        displayedPhrases = viewModel.selectablePhrases
                    }
                    
                    ButtonView(
                        image: "img-pencilSymbol",
                        title: String(localized: "confirm phrase"),
                        titleDone: String(localized: "phrase submitted"),
                        action: {
                            print("Submitted phrase: \(selectedPhrase)")
                            if let phrase = selectedPhrase {
                                viewModel.submitPhrase(phrase: phrase.text)
                                viewModel.toggleReady()
                            }
                        },
                        state: isButtonInactive ? .inactive : .enabled
                    )
                    .id(selectedPhrase?.text)
                }
                .padding(.horizontal)
            }
        }
        .background(Color.darkerPurple)
        .navigationBarBackButtonHidden(true)

        .onAppear {
            viewModel.startPhase()
            viewModel.resetAllPlayersReady()
        }

//        .onChange(of: viewModel.haveTimeRunOut) { oldValue, newValue in
//            if newValue {
//                nextScreen = true
//            }
//        }
        .onChange(of: viewModel.allReady) { oldValue, newValue in
            if newValue {
                nextScreen = true
            }
        }
        
//        .onChange(of: nextScreen) {
//            viewModel.resetAllPlayersReady()
//        }
        
        .navigationDestination(isPresented: $nextScreen) {
            ImageSelectionView()
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

