import SwiftUI
import GameKit

struct HomeView: View {
    @ObservedObject var viewModel = HomeViewModel()
    
    @State private var goToLobby = false
    
    let floatingImages = [
            FloatingImage(name: "img-homeSymbolOrange", x: 0.40, y: 0.15),
            FloatingImage(name: "img-homeSymbolPink", x: 0.15, y: 0.30),
            FloatingImage(name: "img-homeSymbolBlue", x: 0.85, y: 0.30),
            FloatingImage(name: "img-homeSymbolOrange", x: 0.16, y: 0.72),
            FloatingImage(name: "img-homeSymbolGreen", x: 0.90, y: 0.72),
            FloatingImage(name: "img-homeSymbolPink", x: 0.60, y: 0.87),
        ]

    var body: some View {
        NavigationStack {
                GeometryReader { geo in
                    VStack {
                        VStack {
                            
                            Text(viewModel.isAuthenticated ? "Autenticado: \(GKLocalPlayer.local.displayName)" : "Autenticando...")
                                    .font(.subheadline)
                                    .foregroundColor(viewModel.isAuthenticated ? .green : .yellow)
                            Spacer()
                            Image("img-picktureBanner")
                            Spacer()
                            VStack(alignment: .center, spacing: 16) {
                                Button {
                                    
                                } label: {
                                    Text("how to enter an existing match?")
                                        .font(Font.custom("DynaPuff-Regular", size: 17))
                                        .foregroundStyle(.lilac)
                                        .underline(true, color: .lilac)
                                        
                                }
                                ButtonView(image: "img-gameController", title: "Start Match", titleDone: "", action: { viewModel.startMultiplayerGame() }
                                )
                            }
                        }
                        .padding()
                    }
                    .background(
                        ZStack{
                            Image("img-textureI")
                                .resizable()
                                .scaledToFill()
                                .opacity(0.7)
                            ForEach(floatingImages.indices, id: \.self) { index in
                                    Image(floatingImages[index].name)
                                       // .frame(width: floatingImages[index].size, height: floatingImages[index].size)
                                        .position(
                                            x: floatingImages[index].x * geo.size.width,
                                            y: floatingImages[index].y * geo.size.height
                                        )
                            }
                        }
                        .background(.darkerPurple)
                        .ignoresSafeArea()
                    )
                }
            .onAppear { viewModel.processPendingInvite() }
            .onChange(of: viewModel.isInMatch) {
                            if viewModel.isInMatch { goToLobby = true }
                        }

            .navigationDestination(isPresented: $goToLobby) {
                LobbyView()
            }
        }
    }
}

struct FloatingImage {
    let name: String
    let x: Double
    let y: Double
}

#Preview {
    HomeView()
}
