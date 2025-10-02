import SwiftUI
import GameKit

struct MatchRankingView: View {
    var viewModel: MatchRankingViewModel
    @EnvironmentObject var resetManager: AppResetManagerViewModel
    @State var goHome = false
    
    let imageSubmission = ImageSubmission(
        playerID: "1",
        image: UIImage(systemName: "square.and.arrow.up")!.pngData(),
        submissionTime: Date()
    )
    
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
                    // Topo fixo
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
               
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    TabView(selection: $currentPage){
                    ForEach(Array(imagesHighlights.enumerated()), id: \.0) { index, highlight in
                        VStack {
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
                
                
            }
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

// MARK: - Protocols & Mocks
protocol PlayerRepresentable {
    var displayName: String { get }
    var gamePlayerID: String { get }
}

extension GKPlayer: PlayerRepresentable {}

struct MockPlayer: PlayerRepresentable {
    var displayName: String
    var gamePlayerID: String
}

// MARK: - Mock ImageSubmission
extension ImageSubmission {
    static var mock: ImageSubmission {
        ImageSubmission(
            playerID: "1",
            image: UIImage(named: "img-teste")?.pngData(),
            submissionTime: Date()
        )
    }
}

// MARK: - Mock PlayerSubmission
extension PlayerSubmission {
    static func mock(playerID: String, votes: Int, round: Int) -> PlayerSubmission {
        PlayerSubmission(
            playerID: playerID,
            phrase: "Mock phrase for player \(playerID)",
            imageSubmission: .mock,
            votes: votes,
            round: round
        )
    }
}

// MARK: - Mock Player
extension Player {
    static func mock(id: String, name: String, submissions: [PlayerSubmission]) -> Player {
        let mockGKPlayer = MockGKPlayer(gamePlayerID: id, displayName: name)
        return Player(player: mockGKPlayer, submissions: submissions)
    }
}

// MARK: - Mock GKPlayer
struct MockGKPlayer: PlayerRepresentable {
    var gamePlayerID: String
    var displayName: String
}

// MARK: - Mock ViewModel
final class MockMatchRankingViewModel: MatchRankingViewModel {
    var mockHighlights: [RoundHighlight]
    
    init() {
        let player1 = Player.mock(id: "1", name: "Alice", submissions: [
            .mock(playerID: "1", votes: 5, round: 1),
            .mock(playerID: "1", votes: 3, round: 2)
        ])
        
        let player2 = Player.mock(id: "2", name: "Bob", submissions: [
            .mock(playerID: "2", votes: 8, round: 1),
            .mock(playerID: "2", votes: 2, round: 2)
        ])
        
        let player3 = Player.mock(id: "3", name: "Carol", submissions: [
            .mock(playerID: "3", votes: 4, round: 1),
            .mock(playerID: "3", votes: 7, round: 2)
        ])
        
        let mockPlayers = [player1, player2, player3]
        
        let mockImageSubmission = ImageSubmission.mock
        let mockPlayerSubmission = PlayerSubmission.mock(playerID: "1", votes: 10, round: 1)
        
        let mockHighlight = RoundHighlight(
            round: 1,
            playerSubmission: mockPlayerSubmission,
            playerName: "Alice"
        )
        self.mockHighlights = [mockHighlight]
        
        super.init(gamePlayers: mockPlayers)
    }
    
    override func getRoundHighlights() -> [RoundHighlight] {
        return mockHighlights
    }
}

// MARK: - Preview
struct MatchRankingView_Previews: PreviewProvider {
    static var previews: some View {
        MatchRankingView(viewModel: MockMatchRankingViewModel())
            .environmentObject(AppResetManagerViewModel())
    }
}

//#Preview {
//    MatchRankingView()
//}
