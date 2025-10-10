//
//  HighlightsComponent.swift
//  Pickture
//
//  Created by Fernando Sulzbach on 02/10/25.
//
import SwiftUI

struct HighlightsComponent: View {
    
    let highlights: [HighlightDisplay]
    
    var body: some View {
        VStack(spacing: 28) {
            VStack{
                Text("highlight pictures")
                    .font(Font.custom("DynaPuff-Regular", size: 22))
                    .foregroundStyle(.ice)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 26)
                            
                            .frame(height: 50)
                            .foregroundStyle(.lighterPurple)
                    )
            }
            .padding(.horizontal)
                
            SubmissionTabComponent(highlights: highlights)
        }
        .padding(.top, 28)
      //  .padding(.bottom, 50)
       // .frame(width: 329)
       // .padding(.horizontal, 16)
      //  .frame(height:520)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [.lilac.opacity(0.5), .lighterPink.opacity(0.5)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .shadow(.inner(color: .ice, radius: 2, y: 5))
                )
        )
    }
}

#Preview {
//    HighlightsComponent()
}
