import SwiftUI
import GameKit

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack {
            VStack() {
                if viewModel.isAuthenticated {
                    Text("Autenticado: \(GKLocalPlayer.local.displayName)")
                        .font(.subheadline)
                        .foregroundColor(.green)
                    
                    Spacer()
                    
                    Text("Pickture")
                        .font(.system(size: 36, weight: .bold, design: .default))
                    
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
        .onAppear {
            viewModel.processPendingInvite()
        }
    }
}
