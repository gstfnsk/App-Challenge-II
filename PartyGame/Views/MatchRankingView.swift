import SwiftUI
import GameKit

struct MatchRankingView: View {
    var viewModel = MatchRankingViewModel()
    @EnvironmentObject var resetManager: AppResetManagerViewModel
    @State var goHome = false
////    var highlightPictures: [PlayerSubmission] var highlightPictures: [PlayerSubmission] 

    let imageSubmission = ImageSubmission(
        playerID: "1", image: UIImage(systemName: "square.and.arrow.up")!.pngData(),
        submissionTime: Date()
    )
    
    var body: some View {
        let top3 = viewModel.topPlayers()
        let remaining = viewModel.remainingPlayers()
        
        NavigationStack{
            
            ZStack(alignment: .bottom){
            Image("img-texture2")
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0)
                .ignoresSafeArea(.all)
                
                ScrollView{
                    // Topo fixo
                    VStack (spacing: 0){
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text("game over!")
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundStyle(.lilac)
                                Spacer()
                            }
                            Text("final results")
                                .font(.custom("DynaPuff-Regular", size: 32))
                                .fontWeight(.bold)
                                .foregroundStyle(.ice
                                    .shadow(.inner(color: .lilac, radius: 2, y: 3)))
                        }
                        .padding(.top, 130)
                        .padding(.horizontal)
                        VStack(spacing: 48){
                            HStack(alignment: .center, spacing: 16){
                                if top3.indices.contains(1) {
                                    let second = top3[1]
                                    CircleComponent(
                                        isWinner: false,
                                        name: second.name,
                                        points: second.votes,
                                        secondImage: "img-second"
                                    )
                                    .offset(y: 71)
                                }

                                if top3.indices.contains(0) {
                                    let first = top3[0]
                                    CircleComponent(
                                        isWinner: true,
                                        name: first.name,
                                        points: first.votes,
                                        secondImage: "img-winner"
                                    )
                                }

                                if top3.indices.contains(2) {
                                    let third = top3[2]
                                    CircleComponent(
                                        isWinner: false,
                                        name: third.name,
                                        points: third.votes,
                                        secondImage: "img-third"
                                    )
                                    .offset(y: 71)
                                }
                            }
                            .padding(16)
                            VStack(spacing: 24){
                                // Highlight picktures
                                VStack(spacing: 28){

                                    Text("highlight pictures")
                                        .font(Font.custom("DynaPuff-Regular", size: 22))
                                        .foregroundStyle(.ice)
                                        .background(
                                            RoundedRectangle(cornerRadius: 26)
                                                .frame(width: 329, height: 50)
                                                .foregroundStyle(.lighterPurple)
                                        )

                                    VStack(spacing: 8){
                                        VStack(spacing: 8){
                                            Image("img-teste")
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 312, height: 275)
                                            Text("selected phrase")
                                                .font(Font.custom("DynaPuff-Regular", size: 16))
                                                .foregroundStyle(.ice)
                                        }
                                        .padding(8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 28)
                                                .fill(Color(.lighterPurple))
                                        )
                                        VStack(spacing: 16){
                                            HStack(spacing: 8){
                                                Image("img-teste")
                                                    .resizable()
                                                    .clipShape(Circle())
                                                    .frame(width: 30, height: 30)
                                                VStack(alignment: .leading){
                                                    Text("author:")
                                                        .font(.system(size: 15))
                                                    Text("username")
                                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                                        .foregroundStyle(Color(.ice))
                                                }
                                                Spacer()

                                                Text("x votes")
                                            }
                                            PageIndicator(numberOfPages: 3, currentPage: 0)

                                        }
                                    }
                                    .padding(.all)
                                }
                                .padding(16)
                                .padding(.top, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 32)
                                        .frame(width: 361, height: 517)
                                        .foregroundStyle(LinearGradient(
                                            gradient: Gradient(colors: [.lilac.opacity(0.5), .lighterPink.opacity(0.5)]),
                                            startPoint: .top,
                                            endPoint: .bottom).shadow(.inner(color: .ice, radius: 2, y: 5))))
                                //Complete Rank
                                VStack(spacing: 16){
                                    Text("complete rank")
                                        .font(.custom("DynaPuff-Regular", size: 22))
                                        .foregroundStyle(.ice)
                                        .background(RoundedRectangle(cornerRadius: 26)
                                            .fill(.lighterPurple)
                                            .frame(width: 329, height: 50))

                                    VStack(spacing: 0){
                                        RemainingPlayers(remaining: remaining, viewModel: viewModel)
                                    }


                                    .background(RoundedRectangle(cornerRadius: 24)
                                        .foregroundStyle(.lighterPurple.shadow(.inner(color: .darkerPurple, radius: 2, y: 3))))

                                }

                                .padding(.vertical, 28)
                                .frame(width: 329)
                                .padding(.horizontal, 16)
                                .background(RoundedRectangle(cornerRadius: 32)
                                    .foregroundStyle(LinearGradient(
                                        gradient: Gradient(colors: [.lilac.opacity(0.5), .lighterPink.opacity(0.5)]),
                                        startPoint: .top,
                                        endPoint: .bottom).shadow(.inner(color: .ice, radius: 2, y: 5))))

                            }
                            .padding(16)
                            .padding(.top, 28)
                        }
                    }

                }
                    ButtonView(image: "img-gameController", title: "end match", titleDone: "", action: {})
                        .padding(.horizontal)
                        .offset(x: 0, y: -64)
                       
        }
        .background(Color(.darkerPurple))
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $goHome) {
            HomeView()
    }
}

import SwiftUI

struct PageIndicator: View {
    var numberOfPages: Int
    var currentPage: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.darkerPurple : Color.darkerPurple.opacity(0.3))
                    .frame(width: 10, height: 10)
            }
        }
    }
}

struct ContentView: View {
    @State private var currentPage = 0
    
    var body: some View {
        VStack {
            // Indicador
            PageIndicator(numberOfPages: 3, currentPage: currentPage)
                .padding()
            
            // Botões para testar
            HStack {
                Button("Anterior") {
                    if currentPage > 0 { currentPage -= 1 }
                }
                Button("Próximo") {
                    if currentPage < 2 { currentPage += 1 }
                }
            }
        }
    }
}

struct RemainingPlayers: View {
    var remaining: [(Player, Int)]
    var viewModel = MatchRankingViewModel()
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(Array(remaining.enumerated()), id: \.1.0.id) { index, element in
                let player = element.0
                let points = element.1
                
                PlayerRankingComponent(
                    position: index + 4,
                    player: player,
                    avatar: viewModel.avatar(for: player.player.gamePlayerID)
                )
            }
        }
    }
}



protocol PlayerRepresentable {
    var displayName: String { get }
    var gamePlayerID: String { get }
}

extension GKPlayer: PlayerRepresentable {}

struct MockPlayer: PlayerRepresentable {
    var displayName: String
    var gamePlayerID: String
}

#Preview {
    MatchRankingView()
}
