//
//  VotingView.swift
//  PartyGame
//
//  Created by Giulia Stefainski on 09/09/25.
//

import SwiftUI

struct OnboardingPage {
    let title: String
    let topText: String
    let topImage: String
    let bottomText: String
    let bottomImage: String
}

let pages = [
    OnboardingPage(
        title: "creating the match",
        topText: "1. start a new match and select one of the  game center options.  when all the players arrive, click on \"start game\".",
        topImage: "create-match",
        bottomText: "2. after that, when you and your friends are ready, the game starts in 5 seconds.",
        bottomImage: "ready-button"
    ),
    OnboardingPage(
        title: "phrases and picktures",
        topText: "3. the game begins with every player submitting a phrase in 30 seconds.",
        topImage: "phrases",
        bottomText: "4. once the timer is over, one of the phrases appears and the players have another timer to send a related picture.",
        bottomImage: "send-picture"
    ),
    OnboardingPage(
        title: "voting and final results",
        topText: "5. after sending yours, it's time to pick the best one! check every other player's pics and vote for your favorite.",
        topImage: "voting",
        bottomText: "6. after all the rounds, you can see who were the most voted players and the highlight picktures of the match.",
        bottomImage: "winners"
    ),
]

struct OnboardingView: View {
    @State var goToHomeView: Bool = false
    @State var currentPage = 0
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Fundo
                Image("img-textureI")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                // Topo fixo
                VStack (spacing: 0){
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text("welcome!")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundStyle(.lilac)
                            Spacer()
                            Button {
                                goToHomeView = true
                                hasSeenOnboarding = true
                            } label: {
                                Text(currentPage == pages.count - 1 ? "done" : "skip").font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundStyle(.lilac)
                            }
                        }
                        Text("learn how to play")
                            .font(.custom("DynaPuff-Medium", size: 28))
                            .foregroundStyle(.ice
                                .shadow(.inner(color: .lilac, radius: 2, y: 3)))
                    }
                    .padding(.top, 30)
                    .padding(.horizontal)
                    OnboardingBackground {
                        TabView (selection: $currentPage) {
                            ForEach(pages.indices, id: \.self) { i in
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(pages[i].title)
                                        .font(.custom("DynaPuff", size: 22))
                                        .foregroundStyle(.ice.shadow(.inner(color: .lilac, radius: 2, y: 3)))
                                        .padding(.top, 18) // distância do topo do RoundedRectangle

                                    VStack(alignment: .center, spacing: 24) {
                                        VStack(spacing: 8) {
                                            Text(pages[i].topText)
                                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                                .foregroundStyle(.lilac)
                                            Image(pages[i].topImage)
                                                .resizable()
                                                .scaledToFit()
                                        }
                                        VStack(spacing: 8) {
                                            Text(pages[i].bottomText)
                                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                                .foregroundStyle(.lilac)
                                            Image(pages[i].bottomImage)
                                                .resizable()
                                                .scaledToFit()
                                        }
                                    }
                                }
                                .padding(.horizontal, 28) // padding lateral
                                .padding(.top, 14)
                                .padding(.bottom, 72)
                            }
                        }
                    }
                    .padding(.top, 26)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .onAppear {
                        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.lighterPink
                        UIPageControl.appearance().pageIndicatorTintColor = UIColor.lighterPink.withAlphaComponent(0.3)
                    }
                }
                .padding(.top, 26)
                .padding(.horizontal, 16)
                .padding(.bottom, 34)
            }
            .navigationDestination(isPresented: $goToHomeView) {
                HomeView()
            }
            .navigationBarBackButtonHidden(true)
            .background(Color.darkerPurple)
        }
    }
}

struct OnboardingBackground<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32)
                .fill(.darkerPurple
                    .shadow(.inner(color: Color.lighterPurple, radius: 1, x: 0, y: 3)))
            content
        }
    }
}


#Preview {
    OnboardingView()
}
