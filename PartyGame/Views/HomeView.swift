import SwiftUI
import GameKit

struct HomeView: View {
    @ObservedObject var viewModel = HomeViewModel()
    @State var showPopover = false
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
                ZStack {
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
                                    showPopover.toggle()
                                } label: {
                                    Text("how to enter an existing match?")
                                        .font(Font.custom("DynaPuff-Regular", size: 17))
                                        .foregroundStyle(.lilac)
                                        .underline(true, color: .lilac)
                                }
                                ButtonView(image: "img-gameController", title: String(localized: "new match"), titleDone: "", action: { viewModel.startMultiplayerGame() }, changeToDone: false)
                            }
                        }
                        .padding()
                    }
                    if showPopover {
                        // camada de fundo transparente que captura clique
                        Color.black.opacity(0.00001) // invisível mas captura toque
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                showPopover = false
                            }
                        VStack (alignment: .leading){
                            ArrowPopover(arrowEdge: .bottom) {
                                VStack(spacing: 8) {
                                    HStack {
                                        Text("How to enter an existing match?")
                                            .foregroundColor(Color.ice)
                                            .font(Font.custom("DynaPuff-Medium", size: 22))
                                            .lineLimit(2)
                                            .fixedSize(horizontal: false, vertical: true)
                                        Spacer()
                                        Button {
                                            showPopover = false
                                        } label: {
                                            Image("close-button")
                                        }
                                    } .padding(.horizontal, 8)
                                    
                                    Text("1. allow game center notifications on your device settings.").foregroundColor(Color.ice)
                                        .font(.body)
                                        .lineLimit(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Image("game-center-print")
                                        .scaledToFit()
                                    Spacer(minLength: 2.0)
                                    Text("2. when your friend's invitation arrives, all you gotta do is click the notification to join the match.").foregroundColor(Color.ice)
                                        .font(.body)
                                        .lineLimit(3)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Image("notification")
                                        .scaledToFit()
                                    Spacer()
                                }
                            }
                        }
                        .offset(x: 0, y: 68)
                        .frame(width: 361, height: 452, alignment: .bottom)
                        .transition(.scale)
                        .zIndex(1)
                    }
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
            .navigationBarBackButtonHidden(true)
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
