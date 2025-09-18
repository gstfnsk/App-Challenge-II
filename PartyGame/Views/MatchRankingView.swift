import SwiftUI
import GameKit

struct MatchRankingView: View {
    @ObservedObject var viewModel: MatchRankingViewModel
    
    let players: [Player]
    
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
    
    init(viewModel: MatchRankingViewModel) {
        self.viewModel = viewModel
        
        let imageSubmission = ImageSubmission(
            image: UIImage(systemName: "square.and.arrow.up")!.pngData(),
            submissionTime: Date()
        )
        
        let mockPlayer1 = MockPlayer(displayName: "Tester 1", gamePlayerID: "12345")
        let mockPlayer2 = MockPlayer(displayName: "Tester 2", gamePlayerID: "12345")
        let mockPlayer3 = MockPlayer(displayName: "Tester 3", gamePlayerID: "12345")
        let mockPlayer4 = MockPlayer(displayName: "Tester 4", gamePlayerID: "12345")
        
        let playerSubmission1 = PlayerSubmission(player: mockPlayer1, phrase: "", imageSubmission: imageSubmission, votes: 10)
        let playerSubmission2 = PlayerSubmission(player: mockPlayer2, phrase: "", imageSubmission: imageSubmission, votes: 21)
        let playerSubmission3 = PlayerSubmission(player: mockPlayer3, phrase: "", imageSubmission: imageSubmission, votes: 18)
        let playerSubmission4 = PlayerSubmission(player: mockPlayer4, phrase: "", imageSubmission: imageSubmission, votes: 40)
        
        self.players = [
            Player(player: mockPlayer1, submissions: [playerSubmission1, playerSubmission2]),
            Player(player: mockPlayer2, submissions: [playerSubmission3, playerSubmission4]),
            Player(player: mockPlayer3, submissions: [playerSubmission4]),
            Player(player: mockPlayer4, submissions: [playerSubmission2, playerSubmission3])
        ]
    }
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 0) {
                Text("The winner is:")
                    .font(Font.custom("DynaPuff-Regular", size: 16))
                    .foregroundColor(.darkerPurple)

                Text(winner?.player.displayName ?? "No winner")
                    .font(Font.custom("DynaPuff-Regular", size: 32))
                    .foregroundColor(.darkerPurple)
            }
            
            ScrollView {
                RankingComponent(players: players)
            }
            Spacer()
            ButtonHighFidelityView(image: "", title: "Play Again", action: {})
            ButtonHighFidelityView(image: "", title: "Quit", action: {})
        }
        .padding(.all)
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
    MatchRankingView(viewModel: MatchRankingViewModel(service: GameCenterService.shared))
}
