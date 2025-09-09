//
//  PhraseComponent.swift
//  PartyGame
//
//  Created by Lorenzo Fortes on 09/09/25.
//

import SwiftUI

struct PhraseComponent: View {
    @State var phrase: String
    @State var isSelected: Bool = false
    
    init(phrase: String) {
        self.phrase = phrase
    }
    
    var body: some View {
        Button {
            isSelected.toggle()
            
        } label: {
            Text(phrase)
                .foregroundStyle(.background)
                .padding(.vertical, 5)
                .padding(.horizontal)
                .font(.system(size: 12)
                )
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? .black : .gray)
                        .foregroundStyle(.tertiary)
                        .frame(width: 184, height: 36)
                    
                )
                .padding(.horizontal, 12)
            
        }
    }
}

#Preview {
    PhraseComponent(phrase: "Random Phrase")
}
