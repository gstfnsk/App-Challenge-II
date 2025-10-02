import SwiftUI
import GameKit

struct MatchRankingView: View {
    var viewModel: MatchRankingViewModel
    @EnvironmentObject var resetManager: AppResetManagerViewModel
    @State var goHome = false
    
    var body: some View {
        let top3 = viewModel.topPlayers()
        let remainingPlayers = viewModel.remainingPlayers()
        let imagesHighlights = viewModel.getRoundHighlights()
        
        NavigationStack {
            ZStack(alignment: .bottom) {
                Image("img-texture2")
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: 0)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 0) {
                        
                        // Cabeçalho
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
                                .foregroundStyle(.ice.shadow(.inner(color: .lilac, radius: 2, y: 3)))
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 48) {
                            // Top 3 players
                            HStack(alignment: .center, spacing: 16) {
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
                            
                            // Highlights
                            VStack(spacing: 24) {
                                HighlightsView(imagesHighlights: imagesHighlights, viewModel: viewModel)
                            }
                        }
                        
                        // Complete Rank
                        VStack(spacing: 16) {
                            Text("complete rank")
                                .font(.custom("DynaPuff-Regular", size: 22))
                                .foregroundStyle(.ice)
                                .background(
                                    RoundedRectangle(cornerRadius: 26)
                                        .fill(.lighterPurple)
                                        .frame(width: 329, height: 50)
                                )
                            
                            VStack(spacing: 0) {
                                RemainingPlayers(remaining: remainingPlayers, viewModel: viewModel)
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .foregroundStyle(.lighterPurple.shadow(.inner(color: .darkerPurple, radius: 2, y: 3)))
                            )
                        }
                        .padding(.vertical, 28)
                        .frame(width: 329)
                        .padding(.horizontal, 16)
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
                    .padding(16)
                    .padding(.top, 28)
                }
                
                // Botão de encerrar
                ButtonView(image: "img-gameController", title: "end match", titleDone: "", action: {})
                    .padding(.horizontal)
                    .offset(x: 0, y: -64)
            }
            .background(Color(.darkerPurple))
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $goHome) {
                HomeView()
            }
        }
    }
}

// MARK: - Page Indicator
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

// MARK: - Remaining Players
struct RemainingPlayers: View {
    var remaining: [(Player, Int)]
    var viewModel: MatchRankingViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(Array(remaining.enumerated()), id: \.1.0.id) { index, element in
                let player = element.0
                
                PlayerRankingComponent(
                    position: index + 4,
                    player: player,
                    avatar: viewModel.avatar(for: player.player.gamePlayerID)
                )
            }
        }
    }
}

// MARK: - Highlights
struct HighlightsView: View {
    let imagesHighlights: [RoundHighlight]
    let viewModel: MatchRankingViewModel
    
    @State private var currentPage: Int = 0
    
    var body: some View {
        VStack(spacing: 28) {
            Text("highlight pictures")
                .font(Font.custom("DynaPuff-Regular", size: 22))
                .foregroundStyle(.ice)
                .background(
                    RoundedRectangle(cornerRadius: 26)
                        .frame(width: 329, height: 50)
                        .foregroundStyle(.lighterPurple)
                )
            
            VStack(alignment: .center, spacing: 16) {
                TabView(selection: $currentPage) {
                    ForEach(Array(imagesHighlights.enumerated()), id: \.0) { index, highlight in
                        VStack {
                            Text("Placeholder: Highlight content should be here.")
                            if let data = highlight.playerSubmission.imageSubmission.uiImage {
                                Image(uiImage: data)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 312, height: 275)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                            }
                            
                            HStack {
                                if let avatar = viewModel.avatar(for: highlight.playerSubmission.playerID) {
                                    Image(uiImage: avatar)
                                        .resizable()
                                        .clipShape(Circle())
                                        .frame(width: 30, height: 30)
                                }
                                VStack(alignment: .leading) {
                                    Text("author:")
                                        .font(.system(size: 13))
                                    Text(highlight.playerName)
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundStyle(Color(.ice))
                                }
                                Spacer()
                                Text("\(highlight.playerSubmission.votes) votes")
                                    .font(.system(size: 15))
                            }
                        }
                        .tag(index)
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color.lighterPurple))
                        .padding()
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                PageIndicator(numberOfPages: imagesHighlights.count, currentPage: currentPage)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 28)
        .frame(width: 329)
        .padding(.horizontal, 16)
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
