import SwiftUI
import GameKit

struct MatchRankingView: View {
    var viewModel = MatchRankingViewModel()
    @State var closeRanking = false
    
    let players: [Player] = []
    
    var winner: Player? {
        var votes = 0
        var winner: Player?
        for player in players {
            if player.votes >= votes {
                winner = player
                votes = player.votes
            }
        }
        return winner
    }
        let imageSubmission = ImageSubmission(
            playerID: "1", image: UIImage(systemName: "square.and.arrow.up")!.pngData(),
            submissionTime: Date()
        )
    
    var body: some View {
        NavigationStack{
        ZStack{
            Image("img-texture2")
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0)
                .edgesIgnoringSafeArea(.all)
            ScrollView{
                // Topo fixo
                VStack (spacing: 0){
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text("game over!")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundStyle(.lilac)
                            Spacer()
                            //                            Button {
//                            } label: {
//
//                            }
                        }
                        Text("final results")
                            .font(.custom("DynaPuff-Regular", size: 32))
                            .fontWeight(.bold)
                            .foregroundStyle(.ice
                                .shadow(.inner(color: .lilac, radius: 2, y: 3)))
                    }
                    .padding(.top, 30)
                    .padding(.horizontal)
                    VStack(spacing: 48){
                        HStack(alignment: .center, spacing: 16){
                            CircleComponent(isWinner: false, name: "mrlorenzo1608", points: 9, secondImage: "img-second")
                                .offset(y:71)
                            CircleComponent(isWinner: true, name: "mrfernandos", points: 10, secondImage: "img-winner")
                            CircleComponent(isWinner: false, name: "rntoneto", points: 8, secondImage: "img-third")
                                .offset(y:71)
                        }
                        .padding(16)
                        
                        //Highlight picktures
                        
                        RoundedRectangle(cornerRadius: 32)
                            .frame(width: 361, height: 517)
                            .foregroundStyle(LinearGradient(
                                gradient: Gradient(colors: [.lilac.opacity(0.5), .lighterPink.opacity(0.5)]),
                                startPoint: .top,
                                endPoint: .bottom).shadow(.inner(color: .ice, radius: 2, y: 5)))
                    }
                    .padding(.top)
                }
            }
        }
        .background(Color(.darkerPurple))
        }
        .navigationBarBackButtonHidden(true)
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
