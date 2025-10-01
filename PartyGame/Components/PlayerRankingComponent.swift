//
//  PlayerRankingComponent.swift
//  Pickture
//
//  Created by Lorenzo Fortes on 01/10/25.
//

import SwiftUI

struct PlayerRankingComponent: View {
    var position: Int
    var player: Player
    var avatar: UIImage?
    
    var body: some View {
        
        
        HStack(spacing: 16){
            Text(String(position))
                .font(.custom("DynaPuff-Regular", size: 16))
                .foregroundStyle(Color(.ice))
                .background(
            Circle()
                .frame(width: 22, height: 22)
                .foregroundStyle(.lighterBlue.shadow(.inner(color: .darkerBlue, radius: 1, x: 0, y: 0.5 )))
            )
            HStack(spacing: 8){
                if let avatar = avatar {
                                   Image(uiImage: avatar)
                                       .resizable()
                                       .clipShape(Circle())
                                       .frame(width: 30, height: 30)
                               } else {
                                   Image(systemName: "person.crop.circle.fill")
                                       .resizable()
                                       .foregroundColor(.gray)
                                       .frame(width: 30, height: 30)
                               }
                
                Text(player.player.displayName)
                    .font(.system(size: 17,weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(.ice))
                
                Spacer()
                
                Text("\(player.votes) Points")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(Color(.ice))
            }
        }
        .frame(height: 52)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

//#Preview {
//    PlayerRankingComponent()
//}
