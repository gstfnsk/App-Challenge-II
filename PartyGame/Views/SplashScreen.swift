//
//  SplashScreen.swift
//  Pickture
//
//  Created by Lorenzo Fortes on 30/09/25.
//

import SwiftUI
import GameKit

struct SplashScreen: View {
    
    let floatingImages = [
            FloatingImage(name: "img-homeSymbolOrange", x: 0.40, y: 0.15),
            FloatingImage(name: "img-homeSymbolPink", x: 0.15, y: 0.30),
            FloatingImage(name: "img-homeSymbolBlue", x: 0.85, y: 0.30),
            FloatingImage(name: "img-homeSymbolOrange", x: 0.16, y: 0.72),
            FloatingImage(name: "img-homeSymbolGreen", x: 0.90, y: 0.72),
            FloatingImage(name: "img-homeSymbolPink", x: 0.60, y: 0.87),
        ]

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                VStack {
                    VStack {
                        Spacer()
                        Image("img-picktureBanner")
                        Spacer()
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    ZStack{
                        Image("img-textureI")
                            .resizable()
                            .scaledToFill()
                            .opacity(0.7)
                        ForEach(floatingImages.indices, id: \.self) { index in
                            Image(floatingImages[index].name)
                                .position(
                                    x: floatingImages[index].x * geo.size.width,
                                    y: floatingImages[index].y * geo.size.height
                                )
                        }
                    }
                        .background(.darkerPurple)
                        .ignoresSafeArea()
                )
            }
        }
    }
}

#Preview {
    SplashScreen()
}
