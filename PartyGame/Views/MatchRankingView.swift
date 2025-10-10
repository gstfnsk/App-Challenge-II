import SwiftUI
import GameKit

struct MatchRankingView: View {
    var viewModel: MatchRankingViewModel
    @State var goHome = false
    
    var body: some View {
        let rankedPlayers = viewModel.topPlayers()
        let gameHighlights = viewModel.getGameHighlights()
        let highlightsToShow = viewModel.convertHighlights(gameHighlights)
        
        NavigationStack {
            ZStack(alignment: .bottom) {
                
                ScrollView {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text("game over!")
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundStyle(.lilac)
                                Spacer()
                            }
//                            Text("phrases array \(viewModel.service.phrases)")
//                                .font(.custom("DynaPuff-Regular", size: 32))
//                                .fontWeight(.bold)
//                                .foregroundStyle(.ice.shadow(.inner(color: .lilac, radius: 2, y: 3)))
                        }
                        
                        // Top 3 players
                        PodiumComponent(topPlayers: rankedPlayers)
                        
                        // Responsivo (sem altura fixa)
                        HighlightsComponent(highlights: highlightsToShow)
                            .frame(height: 520)
                    }
                                    }
                .scrollIndicators(.hidden)
                
                // Botão de encerrar
                ButtonView(image: "img-gameController", title: "end match", titleDone: "", action: {})
            }
            .padding(.horizontal, 16)
            .background(
                    Image("img-texture2")
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .edgesIgnoringSafeArea(.all)
                        .background(
                            Color(.darkerPurple)
                        )
            )
            
        }
        .onAppear{
            viewModel.resetAllPlayersReady()
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $goHome) {
            HomeView()
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

// MARK: - Protocols & Mocks
protocol PlayerRepresentable {
    var displayName: String { get }
    var gamePlayerID: String { get }
}

extension GKPlayer: PlayerRepresentable {}

#Preview {
//    MatchRankingView(viewModel: MatchRankingViewModel(gamePlayers: []))
}
