//
//  LobbyView.swift
//  PartyGame
//
//  Created by Rafael Toneto on 10/09/25.
//

import SwiftUI

struct LobbyView: View {
    @ObservedObject var viewModel = LobbyViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var scrollTrigger = 0
    @State private var startGame: Bool = false
    @State private var dragProgress: Double = 0.0
    @State private var isDragging: Bool = false
    @State private var keyboardHeight: CGFloat = 0
    
    @State var resetSlider: Bool = false
    var body: some View {
        ZStack{
            Image("img-textureI")
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 26) {
                Text("match lobby")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(.ice)
                
                VStack(spacing: 16) {
                    HStack (spacing: 16){
                        Text("\(viewModel.playerRows.count) players")
                            .font(.custom("Dynapuff-Regular", size: 22))
                            .foregroundStyle(.ice)
                            .frame(maxWidth: 205, alignment: .leading)
                        
                        Text("ready?")
                            .font(.custom("Dynapuff-Regular", size: 22))
                            .foregroundStyle(.ice)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 26)
                        .fill(Color.lighterPurple.shadow(.inner(color: .darkerPurple, radius: 2, y: 3))))
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(viewModel.playerRows) { row in
                                HStack(spacing: 14) {
                                    if let img = viewModel.avatar(for: row.id) {
                                        Image(uiImage: img)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 30, height: 30)
                                            .clipShape(RoundedRectangle(cornerRadius: 7))
                                    } else {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 7)
                                                .fill(Color.white.opacity(0.12))
                                            Text(row.name.split(separator: " ")
                                                .prefix(2).compactMap { $0.first }
                                                .map(String.init).joined().uppercased())
                                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                                .foregroundStyle(.ice)
                                        }
                                        .frame(width: 30, height: 30)
                                        .clipShape(RoundedRectangle(cornerRadius: 7))
                                    }
                                    
                                    Text(row.isMe ? "\(row.name) (you)" : row.name)
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                        .frame(maxWidth: 207, alignment: .leading)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer(minLength: 0)
                                    
                                    Image(row.isReady ? "img-ready" : "img-notReady")
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(row.isMe ? Color.darkerPurple.opacity(0.6) : .clear)
                                .overlay(alignment: .bottom) {
                                    if row.id != viewModel.playerRows.last?.id {
                                        Rectangle()
                                            .fill(Color.black.opacity(0.12))
                                            .frame(height: 1)
                                    }
                                }
                            }
                        }
                    }
                    .frame(width: 329, height: 156)
                    .background(Color.lighterPurple)
                    .clipShape(RoundedRectangle(cornerRadius: 26))
                }
                .padding(.horizontal)
                .padding(.vertical)
                .background(GradientBackground())
                .frame(maxHeight: 256, alignment: .top)
                
                SliderView(
                    latchesOn: false,
                    
                    onComplete: { isReady in
                        if isReady != viewModel.isLocalReady {
                            viewModel.toggleReady()
                        }
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isDragging = false
                            dragProgress = isReady ? 1.0 : 0.0
                        }
                    },
                    
                    onDrag: { progress in
                        dragProgress = progress
                        isDragging = true
                    },
                    shouldReset: $resetSlider,
                    configuration: SliderViewConfiguration {
                        ZStack(alignment: .center){
                            Capsule()
                                .fill(smoothBackgroundGradient)
                                .frame(width: 361, height: 53)
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.35), lineWidth: 10)
                                        .blur(radius: 10)
                                        .mask(Capsule().fill(LinearGradient(
                                            colors: [.black, .clear],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )))
                                )
                                .animation(.easeOut(duration: 0.15), value: currentGradientState)
                            Text(sliderText)
                                .foregroundColor(Color.ice)
                                .font(Font.custom("DynaPuff-Medium", size: 24))
                                .shadow(color: .black.opacity(0.2), radius: 1)
                                .animation(.easeInOut(duration: 0.2), value: sliderText)
                        }
                    } foreground: {
                        EmptyView()
                    } track: {
                        Circle()
                            .frame(height: 40)
                            .foregroundStyle(Color.ice)
                            .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
                            .padding(6)
                            .scaleEffect(isDragging ? 1.05 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: isDragging)
                    } knob: {
                        Image(systemName: knobIcon)
                            .foregroundStyle(knobColor)
                            .fontWeight(.black)
                    }
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .safeAreaInset(edge: .bottom, spacing: 16) {
                ChatCard(
                    messages: viewModel.chat,
                    scrollTrigger: $scrollTrigger,
                    draft: $viewModel.typedMessage,
                    onSend: {
                        viewModel.sendMessage()
                        scrollTrigger &+= 1
                    },
                    avatarFor: viewModel.avatar(for:)
                )
                .padding(.horizontal)
                .padding(.bottom, keyboardHeight)
            }
        }
        .background(Color.darkerPurple)
        .navigationBarBackButtonHidden(true)
        .onChange(of: viewModel.allReady) { _, newValue in
            if newValue && !viewModel.playerRows.isEmpty {
                startGame = true
            }
        }
        .onAppear {
            resetSlider.toggle()
        }
        .onChange(of: startGame) {
            viewModel.resetAllPlayersReady()
        }
        .navigationDestination(isPresented: $startGame) {
            CountDownView()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(role: .cancel) {
                    viewModel.leaveLobby()
                    viewModel.isInMatch = false
                    dismiss()
                } label: { Image(systemName: "chevron.left") }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)) { note in
            guard
                let end = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                let duration = note.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
            else { return }

            let screenH = UIScreen.main.bounds.height
            let height = max(0, screenH - end.origin.y)
            withAnimation(.easeOut(duration: duration)) {
                keyboardHeight = height
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { note in
            let duration = (note.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.25
            withAnimation(.easeOut(duration: duration)) {
                keyboardHeight = 0
            }
        }
    }
    
    var header: some View {
        HStack(spacing: 12) {
            Text("Jogadores conectados")
                .font(.headline)
            Spacer()
            if viewModel.allReady && !viewModel.playerRows.isEmpty {
                Text("Todos prontos ✅")
                    .font(.subheadline)
                    .foregroundStyle(.green)
            } else {
                Text("\(viewModel.playerRows.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
        
    enum GradientState: Equatable {
        case initial
        case startDragging
        case midDragging
        case completed
    }
    
    var currentGradientState: GradientState {
        if viewModel.isLocalReady && !isDragging {
            return .completed
        } else if isDragging {
            if dragProgress < 0.5 && dragProgress > 0 {
                return .startDragging
            } else if dragProgress < 0.8 {
                return .midDragging
            } else {
                return .completed
            }
        }
        else if dragProgress == 0 {
            return .initial
        } else {
            return .startDragging
        }
    }
    
    var smoothBackgroundGradient: LinearGradient {
        switch currentGradientState {
        case .initial:
            return LinearGradient(
                colors: [Color.darkerRed, Color.lighterRed],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .startDragging:
            return LinearGradient(
                colors: [Color.darkerRed, Color.darkerGreen],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .midDragging:
            return LinearGradient(
                colors: [Color.darkerRed, Color.darkerGreen, Color.lighterGreen],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .completed:
            return LinearGradient(
                colors: [Color.lighterGreen, Color.darkerGreen],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    var sliderText: String {
        switch currentGradientState {
        case .initial, .startDragging:
            return "ready?"
        case .midDragging:
            return dragProgress > 0.8 ? "ready!" : "ready?"
        case .completed:
            return "ready!"
        }
    }
    
    var knobIcon: String {
        dragProgress > 0.8 ? "checkmark" : "chevron.right"
    }
    
    var knobColor: Color {
        dragProgress > 0.8 ? .darkerGreen : .darkerRed
    }
}

private struct ChatCard: View {
    let messages: [LobbyViewModel.ChatItem]
    @Binding var scrollTrigger: Int
    @Binding var draft: String
    var onSend: () -> Void
    var avatarFor: (String) -> UIImage?

    @FocusState private var inputFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("chat with your friends")
                .font(.custom("DynaPuff-Medium", size: 28))
                .foregroundStyle(.ice)

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 18) {
                        ForEach(messages) { m in
                            MessageRow(item: m, avatar: avatarFor(m.senderID))
                                .id(m.id)
                        }
                    }
                    .padding(.top, 2)
                }
                .frame(maxHeight: .infinity)
                .onChange(of: scrollTrigger) {
                    if let last = messages.last?.id {
                        withAnimation { proxy.scrollTo(last, anchor: .bottom) }
                    }
                }
                .onChange(of: messages.count) { _, _ in
                    if let last = messages.last?.id {
                        DispatchQueue.main.async {
                            withAnimation { proxy.scrollTo(last, anchor: .bottom) }
                        }
                    }
                }
            }

            Rectangle().fill(Color.lilac.opacity(0.35)).frame(height: 1)

            HStack(spacing: 12) {
                ZStack(alignment: .leading) {
                    if draft.isEmpty {
                        Text("send a message")
                            .foregroundStyle(.ice.opacity(0.8))
                            .font(.system(size: 16))
                    }

                    TextField("", text: $draft)
                        .textFieldStyle(.plain)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(.ice)
                        .submitLabel(.done)
                        .focused($inputFocused)
                        .onSubmit { inputFocused = false }
                }

                Button {
                    guard !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                    onSend()
                    inputFocused = false
                } label: {
                    ZStack {
                        Circle().fill(Color.lilac.shadow(.inner(color: .ice, radius: 2, y: 3))).frame(width: 48, height: 48)
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color.darkerPurple)
                            .rotationEffect(.degrees(8))
                    }
                }
            }
        }
        .padding(16)
        .frame(width: 361, height: 335, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(Color.darkerPurple.shadow(.inner(color: .lighterPurple, radius: 2, y: 3)))
        )
        .contentShape(Rectangle())
        .onTapGesture { inputFocused = false }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { inputFocused = false }
            }
        }
    }
}

private struct MessageRow: View {
    let item: LobbyViewModel.ChatItem
    let avatar: UIImage?

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Group {
                if let img = avatar {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.12))
                        Text(initials(of: item.senderName))
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(.ice)
                    }
                }
            }
            .frame(width: 22, height: 22)
            .clipShape(RoundedRectangle(cornerRadius: 6))

            (
                Text(item.isLocal ? "\(item.senderName) (you)" : item.senderName)
                    .font(.custom("DynaPuff-Medium", size: 20))
                    .foregroundStyle(item.isLocal ? Color.lilac : Color.yellow)
                + Text(": ")
                    .font(.custom("DynaPuff-Regular", size: 20))
                    .foregroundStyle(.ice)
            )
            .multilineTextAlignment(.leading)

            Text(item.text)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(.ice)

            Spacer(minLength: 0)
        }
    }

    private func initials(of name: String) -> String {
        let parts = name.split(separator: " ")
        let a = parts.first?.first.map(String.init) ?? ""
        let b = parts.dropFirst().first?.first.map(String.init) ?? ""
        return (a + b).uppercased()
    }
}

#Preview {
    LobbyView()
}
