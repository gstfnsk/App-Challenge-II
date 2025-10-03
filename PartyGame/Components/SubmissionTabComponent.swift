//
//  SubmissionTabComponent.swift
//  Pickture
//
//  Created by Fernando Sulzbach on 02/10/25.
//

import SwiftUI

struct SubmissionTabComponent: View {
    
    var images: [Image] = [Image("img-teste"), Image("img-placeholder16x9"), Image("img-teste")]
    
    // Dimensões base dos elementos internos (coerentes com o card base 329×520)
    private let baseImageSize = CGSize(width: 312, height: 275)
    
    var body: some View {
        VStack {
            TabView {
                ForEach(images.indices, id: \.self) { index in
                    VStack {
                        VStack(spacing: 0) {
                            images[index]
                                .resizable()
                                .scaledToFill()
                                .frame(width: baseImageSize.width, height: baseImageSize.height)
                                .clipped()
                                .cornerRadius(24)
                            
                            Text("\"Nome da imagem\"")
                                .font(Font.custom("DynaPuff-Regular", size: 16))
                                .foregroundStyle(Color(.white))
                                .frame(height: 40)
                                .frame(maxWidth: .infinity)
                                .background(Color(.lighterPurple))
                        }
                        .padding(.horizontal, 8)
                        .padding(.top, 8)
                        .background(Color(.lighterPurple))
                        .cornerRadius(32)
                        
                        HStack(alignment: .center, spacing: 8){
                            Image("img-teste")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 0) {
                                Text("author:")
                                
                                HStack(alignment: .center, spacing: 16) {
                                    Text("MrFernandoS")
                                        .font(Font.custom("DynaPuff-Regular", size: 14))
                                        .foregroundStyle(Color(.black))
                                    
                                    Spacer()
                                    
                                    Text("7 votes")
                                        .font(Font.custom("DynaPuff-Regular", size: 14))
                                        .foregroundStyle(Color(.black))
                                }
                            }
                        }
                    }
                    // Garante que cada página “grude” no topo do espaço da TabView
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.horizontal, 32)
                }
            }
            .padding(.bottom)
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .never))
        }
    }
}

#Preview {
    SubmissionTabComponent()
}
