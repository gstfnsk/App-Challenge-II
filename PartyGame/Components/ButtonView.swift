//
//  ButtonView.swift
//  PartyGame
//
//  Created by Giulia Stefainski on 09/09/25.
//

import SwiftUI

struct ButtonView: View {
    var image: String
    var title: String
    var titleDone: String
    var action: () -> Void
    @State var state = ButtonState.enabled
    enum ButtonState {
        case inactive
        case enabled
        case done
    }
    var body: some View {
        Button {
            if state == .enabled {
                action()
                state = .done
            }
            else {
                action()
            }
        } label: {
            if state == .enabled {
                HStack (alignment: .center, spacing: 10) {
                    Image(image)
                        .saturation(1)
                    Text(title)
                        .font(Font.custom("DynaPuff-Regular", size: 24))
                        .foregroundStyle(.darkerPurple)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 53)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            (Color.lilac)
                                .shadow(.inner(color: Color.white, radius: 2, y: 3))
                        )
                )
            }
            if state == .inactive {
                HStack (alignment: .center, spacing: 10) {
                    Image("\(image)Inactive")
                        .saturation(0)
                    Text(title)
                        .font(Font.custom("DynaPuff-Regular", size: 24))
                        .foregroundStyle(.darkerGray)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 53)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            (Color.lighterGray)
                                .shadow(.inner(color: Color.white, radius: 2, y: 3))
                        )
                )
            }
            if state == .done {
                HStack (alignment: .center, spacing: 10) {
                    Image(image)
                        .saturation(1)
                    Text(titleDone)
                        .font(Font.custom("DynaPuff-Regular", size: 24))
                        .foregroundStyle(.darkerPurple)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 53)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            (Color.lighterPink)
                                .shadow(.inner(color: Color.white, radius: 2, y: 3))
                        )
                )
            }
        }
        .disabled(state != .enabled)
    }
}

#Preview {
    ButtonView(image:"img-pencilSymbol", title:"New Match", titleDone: "phrase submitted", action: { print("hi") })
}
