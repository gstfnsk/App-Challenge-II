//
//  ButtonView.swift
//  PartyGame
//
//  Created by Giulia Stefainski on 09/09/25.
//

import SwiftUI

struct ButtonHighFidelityView: View {
    
    var image: String
    var title: String
    var action: () -> Void
    
    @State var enabled: Bool = true
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack (alignment: .center, spacing: 10) {
                
                Image(image)
                    .saturation(enabled ? 1 : 0)
                
                Text(title)
                    .font(Font.custom("DynaPuff-Regular", size: 24))
                    .foregroundStyle(enabled ? .darkerPurple : .darkerGray)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 53)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        (enabled ? Color.lilac : Color.lighterGray)
                        .shadow(.inner(color: Color.white, radius: 2, y: 3))
                    )
            )
            
                
        }
    }
}

#Preview {
    ButtonHighFidelityView(image:"img-gameController", title:"New Match", action: { print("hi") } )
}
