//
//  CountDownView.swift
//  Pickture
//
//  Created by Rafael Toneto on 23/09/25.
//

import SwiftUI

struct CountDownView: View {
    @StateObject private var viewModel: CountDownViewModel

    var onFinish: (() -> Void)?

    @State private var bounce = false
    @State private var goToPhrase = false

    init(from: Int = 5, onFinish: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: CountDownViewModel(from: from))
        self.onFinish = onFinish
    }

    private let floatingImages = [
        FloatingImage(name: "img-timerSymbolGreenHeart", x: 0.40, y: 0.16),
        FloatingImage(name: "img-timerSymbolBlueCross",  x: 0.13, y: 0.34),
        FloatingImage(name: "img-timerSymbolPink",       x: 0.78, y: 0.29),
        FloatingImage(name: "img-timerSymbolGreenCross", x: 0.15, y: 0.96),
        FloatingImage(name: "img-timerSymbolBlueHeart",  x: 0.80, y: 0.88),
        FloatingImage(name: "img-timerSymbolOrange",     x: 0.54, y: 1.07),
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("img-textureI")
                    .resizable()
                    .scaledToFill()
                    .opacity(0.7)

                VStack {
                    Text("\(viewModel.remaining)")
                        .font(.custom("DynaPuff-Medium", size: 300))
                        .foregroundStyle(.ice)
                        .scaleEffect(bounce ? 1.17 : 1.0)
                        .animation(.interpolatingSpring(stiffness: 280, damping: 16),
                                   value: bounce)
                        .padding(.vertical, 8)

                        .onChange(of: viewModel.remaining) { oldValue, newValue in
                            if newValue > 0 {
                                bounce = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                                    bounce = false
                                }
                            } else {
                                onFinish?()
                                goToPhrase = true
                            }
                        }

                        .onAppear {
                            viewModel.reset(autostart: true)
                        }
                        .onDisappear {
                            viewModel.stop()
                        }

                    Image("img-timerLabel")
                        .padding(.top, -75)
                }
                .padding(.bottom, 50)

                ForEach(floatingImages.indices, id: \.self) { idx in
                    let item = floatingImages[idx]
                    Image(item.name)
                        .position(x: item.x * geo.size.width,
                                  y: item.y * geo.size.height)
                }
            }
            .background(.darkerPurple)
            .ignoresSafeArea()
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $goToPhrase) {
            PhraseView()
        }
    }
}
#Preview {
    CountDownView()
}
