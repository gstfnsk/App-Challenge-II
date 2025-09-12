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
                            viewModel.startMatchmaking()
                        }
                    } else {
                        Text("Autenticando no Game Center...")
                            .foregroundColor(.orange)
                    }
                }
                .padding()
            }
            .onAppear { viewModel.processPendingInvite() }
            .onChange(of: viewModel.isInMatch) { inMatch in
                if inMatch { goToLobby = true }
            }

            NavigationLink(
                destination: LobbyView(viewModel: viewModel.makeLobbyViewModel()),
                isActive: $goToLobby
            ) { EmptyView() }
            .hidden()
        }
    }
}
