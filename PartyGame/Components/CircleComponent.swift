//
//  CircleComponent.swift
//  Pickture
//
//  Created by Lorenzo Fortes on 30/09/25.
//

import SwiftUI

struct CircleComponent: View {
    var avatar: String = "img-texture2"
    var color: Color = .lighterPink
    @State var isWinner: Bool 
    var name: String
    var points: Int
    var secondImage: String
    var body: some View {
        VStack(spacing: 26){
            ZStack(alignment: .bottom){
                
                Circle()
                    .stroke(isWinner ? .lighterPink : .lilac, lineWidth: 5)
                    .frame(width: isWinner ? 120 : 80, height: isWinner ? 120 : 80)
                    .background(Image(avatar)
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                    )
                ZStack{
                    Circle()
                        .frame(width: isWinner ? 48 : 36, height: isWinner ? 48 : 36)
                        .foregroundStyle(isWinner ? Color.lighterPink.shadow(.inner(color: .darkerPink, radius: 2, y: 3)) : Color.lilac.shadow(.inner(color: .ice, radius: 2, y: 3)))
                    Image(secondImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: isWinner ? 26 : 21, height: isWinner ? 32 : 24)
                    
                }
                .offset(y: 15)
            }
            VStack(alignment: .center,spacing: 4){
                Text(name)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(.lilac)
                    .lineLimit(1)
                
                Text("\(points) points")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(.ice)
                    .lineLimit(1)
            }
        }
        .frame(width: isWinner ? 120 : 104)
    }
}

//#Preview {
//    CircleComponent()
//}
