//
//  PhraseComponent.swift
//  PartyGame
//
//  Created by Lorenzo Fortes on 09/09/25.
//

import SwiftUI

struct PhraseComponent: View {
    var phrase: Phrase
    var isSelected: Bool = false
    let onSelect: () -> Void
    var isEnabled: Bool = true
    
    var body: some View {
        Button {
            onSelect()
        }
        label: {
            Text(phrase.text)
                .foregroundStyle(.darkerPurple)
                .padding(.vertical, 12)
                .padding(.horizontal)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 297)
                .background(
                    RoundedRectangle(cornerRadius: 26)
                        .fill(isSelected ? Color.lighterPink.shadow(.inner(color: Color.lilac, radius: 2, y: 3)) : Color.lilac.shadow(.inner(color: Color.ice, radius: 2, y: 3)))
                        )
                        
                        .frame(maxHeight: .infinity)
                    
                
        }
        .disabled(!isEnabled)
        
    }
}
#Preview {
    PhraseComponent(phrase: Phrase(text: "Testando um texto gigante para ver como se comporta o componente", category: .action), isSelected: true, onSelect: {})
}

