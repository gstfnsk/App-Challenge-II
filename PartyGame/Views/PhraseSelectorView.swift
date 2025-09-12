//
//  PhraseSelectorView.swift
//  PartyGame
//
//  Created by Lorenzo Fortes on 09/09/25.
//

import SwiftUI

struct PhraseSelectorView: View {
    
    @State var selectedPhrase: Phrase = .init(text: "", category: .action)
    @State var displayedPhrases: [Phrase] = []
    
    @State var nextScreen: Bool = false
        
    let columns = [GridItem(.flexible())]
    var body: some View {
        NavigationStack {
            VStack (spacing: 400) {
                VStack(spacing: 64){
                    ZStack(alignment: .trailing){
                        TextField(
                            "Write down a phrase or select one",
                            text: $selectedPhrase.text)
                        
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity)
                        
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.black, lineWidth: 0.5)
                        )
                        Button{
                            print("Selected random phrase")
                            displayedPhrases = Array(Phrases.all.shuffled().prefix(4))
                        } label:{
                            Image(systemName: "dice.fill")
                                .foregroundStyle(.black)
                                .font(.system(size: 24))
                                .frame(width: 50, height: 50)
                        }
                    }
                    LazyVGrid(columns: columns, spacing: 16){
                        ForEach(displayedPhrases, id: \.self) { phrase in
                            PhraseComponent(phrase: phrase,
                            isSelected: phrase == selectedPhrase,
                                            onSelect: {
                                selectedPhrase = phrase
                            })
                        }
                        
                    }
                    Button {
                        nextScreen = true
                        print("Submitted phrase: \(selectedPhrase)")
                    }label: {
                        Text("Submit Phrase")
                    }
                    .foregroundStyle(.primary)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.tertiary)
                            .frame(width: 356, height: 42)
                    )
                    
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .onAppear() {
                    displayedPhrases = Array(Phrases.all.shuffled().prefix(4))
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $nextScreen) {
            ImageSelectionView(viewModel: ImageSelectionViewModel(service: GameCenterService()), selectedPhrase: selectedPhrase)
        }
        
    }
}
#Preview {
    PhraseSelectorView()
}
