//
//  ButtonView.swift
//  PartyGame
//
//  Created by Giulia Stefainski on 09/09/25.
//

import SwiftUI

struct ButtonView: View {
    var title: String
//    var action: () -> Void
    var body: some View {
        Button {
            ()
        } label: {
            Text(title)
                .frame(maxWidth: .infinity)
        }
    }
}

//#Preview {
//    ButtonView(title:"Confirm vote" action:())
//}
