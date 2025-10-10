//
//  SubmissionTabComponent.swift
//  Pickture
//
//  Created by Fernando Sulzbach on 02/10/25.
//

import SwiftUI

struct SubmissionMock {
    var image: Image
    var phrase: String
    var author: String
    var points: Int
}

struct SubmissionTabComponent: View {
    
    var submissions: [SubmissionMock] = [
        SubmissionMock(
            image: Image("img-riboli"), phrase: "O mentor mais maluco", author: "MrFernandoS", points: 2),
        SubmissionMock(
            image: Image("img-happy"), phrase: "A definição de Felicidade", author: "rntoneto", points: 1),
        SubmissionMock(
            image: Image("img-dog"), phrase: "tenho medo disso", author: "rntoneto", points: 2),
        ]
    
    // Dimensões base dos elementos internos (coerentes com o card base 329×520)
    private let baseImageSize = CGSize(width: 312, height: 275)
    
    var body: some View {
        VStack {
            TabView {
                ForEach(submissions.indices, id: \.self) { index in
                    VStack {
                        VStack(spacing: 0) {
                            submissions[index].image
                                .resizable()
                                .scaledToFill()
                                .frame(width: baseImageSize.width, height: baseImageSize.height)
                                .clipped()
                                .cornerRadius(24)
                            
                            Text("\"\(submissions[index].phrase)\"")
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
                                    Text("\(submissions[index].author)")
                                        .font(Font.custom("DynaPuff-Regular", size: 14))
                                        .foregroundStyle(Color(.black))
                                    
                                    Spacer()
                                    
                                    Text("\(submissions[index].points) votes")
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
