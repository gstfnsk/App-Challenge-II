//
//  PhraseSelectorView.swift
//  PartyGame
//
//  Created by Lorenzo Fortes on 09/09/25.
//

import SwiftUI

struct PhraseSelectorView: View {
    
    let phrases = [
        "Quando o Wi-Fi cai bjn asdkjsand asjdnsado asjndas kdjsand as kjdnas",
        "Segunda-feira de manhã",
        "Eu depois da academia",
        "A cara que você faz quando...",
        "Esperando a pizza chegar",
        "Quando o professor diz: prova surpresa",
        "A reunião que podia ser um e-mail",
        "Quando seu time perde nos acréscimos",
        "Acordei assim",
        "Tentando parecer ocupado",
        "Quando o crush visualiza e não responde",
        "Sexta-feira finalmente",
        "Quando o alarme toca",
        "Só observando",
        "Tentando economizar",
        "Quando acaba a luz no meio do jogo",
        "Eu tentando ser fitness",
        "Quando seu amigo diz: 'confia em mim'",
        "Deu ruim",
        "Quando a fofoca é boa demais"
    ]
    
    @State var selectedPhrase: String = ""
    @State var displayedPhrases: [String] = []
    
    let columns = [GridItem(.flexible())]
    var body: some View {
        VStack (spacing: 400) {
            VStack(spacing: 32){
                ZStack(alignment: .trailing){
                    TextField(
                        "Write down a phrase or select one",
                        text: $selectedPhrase)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.black, lineWidth: 0.5)
                    )
                    Button{
                        print("Selected random phrase")
                        displayedPhrases = Array(phrases.shuffled().prefix(4))
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
                displayedPhrases = Array(phrases.shuffled().prefix(4))
            }
        }
    }
}
#Preview {
    PhraseSelectorView()
}
