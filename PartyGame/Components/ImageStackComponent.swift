import SwiftUI
import Combine


struct ImageStackComponent: View {
    @Binding var cards: [ImageSubmission]
    
    @State private var cardStyles: [UUID: (rotation: Double, direction: CGFloat)] = [:]
    @State private var rotationList: [Double] = []
    @State private var directionList: [CGFloat] = []
    
    @State var currentIndex: Int = 0
    @Binding var isDone: Bool
    
    var timer: Publishers.Autoconnect<Timer.TimerPublisher>
    
    init(cards: Binding<[ImageSubmission]>, isDone: Binding<Bool>, timer: Publishers.Autoconnect<Timer.TimerPublisher>) {
            self._cards = cards
            self.timer = timer
            self._isDone = isDone
            
            let cardCount = cards.count
            self._currentIndex = State(initialValue: cardCount - 1)
            
            self._rotationList = State(initialValue: (0..<cardCount).map { _ in
                Double.random(in: -3...3)
            })
            
            self._directionList = State(initialValue: (0..<cardCount).map { _ in
                CGFloat(Bool.random() ? -1 : 1)
            })
        }
    

    var body: some View {
        GeometryReader { reader in
            ZStack {
                
                ForEach(Array(cards.enumerated().reversed()), id: \.element.id) { (index, card) in
                    
                    ImageCard(reader: reader, index: index, card: card, rotation: rotationList[index], direction: directionList[index], timer: timer, currentIndex: $currentIndex, isDone: $isDone)
                }
            }
        }
    }
    
}

struct ImageCard: View {
    var reader: GeometryProxy
    var index: Int
    var card: ImageSubmission

    @State private var animateOut: Bool = false
    @State private var isVisible: Bool = true
    
    var rotation: Double
    var direction: CGFloat
    var timer: Publishers.Autoconnect<Timer.TimerPublisher>
    
    @Binding var currentIndex: Int
    @Binding var isDone: Bool
    
    var body: some View {
        VStack {
            if let uiImage = card.uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                   // .frame(maxWidth: 300, maxHeight: 500)
                    .clipped()
                    .cornerRadius(20)
                    .shadow(radius: 20)
                    .modifier(Parabola(progress: animateOut ? 1 : 0,
                                       dx: reader.size.width * 1.2,
                                       peak: 120,
                                       direction: direction))
                    .rotationEffect(.degrees(animateOut ? Double(direction) * 20 : rotation))
                    .opacity(isVisible ? 1 : 0)
                    .position(x: reader.size.width / 2,
                              y: reader.size.height / 2)
            }
        }
        .zIndex(Double(index))
        .onReceive(timer) { _ in
            if index == currentIndex {
                withAnimation(.easeOut(duration: 0.5)) {
                    animateOut = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isVisible = false
                    currentIndex -= 1
                    if currentIndex < 0 {
                        isDone = true
                    }
                }
                
            }
        }
    }
}

struct Parabola: AnimatableModifier {
    var progress: Double
    var dx: CGFloat
    var peak: CGFloat
    var direction: CGFloat

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        let x = dx * CGFloat(progress) * direction
        let y = -4 * peak * CGFloat(progress * (1 - progress))
        return content.offset(x: x, y: y)
    }
}

//#Preview {
//    ContentView()
//}
