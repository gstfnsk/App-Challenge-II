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

    
    var body: some View {
        Button {
            onSelect()
            
        } label: {
            Text(phrase.text)
                .foregroundStyle(.background)
                .padding(.vertical, 5)
                .padding(.horizontal)
                .font(.system(size: 17))
                .lineLimit(10)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? .black : .gray)
                        .foregroundStyle(.tertiary)
                        .frame(width: 356)
                        .frame(maxHeight: .infinity)
                    
                )
                .padding(.horizontal, 12)
            
        }
    }
}


