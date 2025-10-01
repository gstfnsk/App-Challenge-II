import SwiftUI
import GameKit

struct MatchRankingView: View {
    var viewModel = MatchRankingViewModel()
    @State var closeRanking = false
    

    let imageSubmission = ImageSubmission(
        playerID: "1", image: UIImage(systemName: "square.and.arrow.up")!.pngData(),
        submissionTime: Date()
    )
    
    var body: some View {
        let top3 = viewModel.topPlayers()
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
                                Button {
                                    viewModel.leaveMatch()
                                } label: {
                                    Image("close-button")
                                }
                            }
                            Text("final results")
                                .font(.custom("DynaPuff-Regular", size: 32))
                                .fontWeight(.bold)
                                .foregroundStyle(.ice
                                    .shadow(.inner(color: .lilac, radius: 2, y: 3)))
                        }
                        //                    .padding(.top, 30)
                        .padding(.top, 130)
                        .padding(.horizontal)
                        VStack(spacing: 48){
                            HStack(alignment: .center, spacing: 16){
                                if top3.indices.contains(1) {
                                    let second = top3[1]
                                    CircleComponent(
                                        isWinner: false,
                                        name: second.0.player.displayName,
                                        points: second.1,
                                        secondImage: "img-second"
                                    )
                                    .offset(y: 71)
                                }
                                
                                if top3.indices.contains(0) {
                                    let first = top3[0]
                                    CircleComponent(
                                        isWinner: true,
                                        name: first.0.player.displayName,
                                        points: first.1,
                                        secondImage: "img-winner"
                                    )
                                }
                                
                                if top3.indices.contains(2) {
                                    let third = top3[2]
                                    CircleComponent(
                                        isWinner: false,
                                        name: third.0.player.displayName,
                                        points: third.1,
                                        secondImage: "img-third"
                                    )
                                    .offset(y: 71)
                                }
                            }
                            .padding(16)
                            
                            //Highlight picktures
                            
                            //                        RoundedRectangle(cornerRadius: 32)
                            //                            .frame(width: 361, height: 517)
                            //                            .foregroundStyle(LinearGradient(
                            //                                gradient: Gradient(colors: [.lilac.opacity(0.5), .lighterPink.opacity(0.5)]),
                            //                                startPoint: .top,
                            //                                endPoint: .bottom).shadow(.inner(color: .ice, radius: 2, y: 5)))
                        }
                        //                    .padding(.top)
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
