//
//  PhraseSelectorView.swift
//  PartyGame
//
//  Created by Lorenzo Fortes on 09/09/25.
//

import SwiftUI

struct PhraseSelectorView: View {
    
    @State var selectedPhrase: String = ""
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
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
                        selectedPhrase = "Random Phrase"
                        
                    } label:{
                        Image(systemName: "dice.fill")
                            .foregroundStyle(.black)
                            .font(.system(size: 24))
                            .frame(width: 50, height: 50)
                    }
                }
                LazyVGrid(columns: columns, spacing: 16){
                    ForEach (0..<4) {_ in
                        PhraseComponent(phrase: selectedPhrase)
                    }
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
    }
}

#Preview {
    PhraseSelectorView()
}
