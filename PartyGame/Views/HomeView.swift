import SwiftUI
import GameKit

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var goToLobby = false

    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    if viewModel.isAuthenticated {
                        Text("Autenticado: \(GKLocalPlayer.local.displayName)")
                            .font(.subheadline)
                            .foregroundColor(.green)

                        Spacer()

                        Text("Pickture")
                            .font(.system(size: 36, weight: .bold))

                        Spacer()

                        Button("Iniciar Partida") {
                            viewModel.startSinglePlayerGame()
                        }
                    } else {
                        Text("Autenticando no Game Center...")
                            .foregroundColor(.orange)
                    }
                }
                .padding()
            }
            .onAppear { viewModel.processPendingInvite() }
            .onChange(of: viewModel.isInMatch) {
                if viewModel.isInMatch { goToLobby = true }
            }
            .navigationDestination(isPresented: $goToLobby) {
                    LobbyView(viewModel: viewModel.makeLobbyViewModel())
                }
        }
    }
}
