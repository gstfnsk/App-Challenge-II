//
//  LobbyView.swift
//  PartyGame
//
//  Created by Rafael Toneto on 10/09/25.
//

//
//  LobbyView.swift
//  PartyGame
//
import SwiftUI
import GameKit

struct LobbyView: View {
    @ObservedObject var viewModel: LobbyViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var scrollTrigger = 0
    @State private var dragProgress: Double = 0.0
    @State private var isDragging: Bool = false
    
    
    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            VStack(spacing: 16){
                playersStrip
                    .padding(.horizontal)
                    .padding(.top, 8)
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
                        //Atualizar UI enquanto Drag
                    },configuration: SliderViewConfiguration {
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
                
            }
            Divider().padding(.top, 8)
            chatArea
            inputBar
            
        }
        .navigationTitle("Lobby")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(role: .cancel) {
                    viewModel.leaveLobby()
                    viewModel.isInMatch = false
                    dismiss()
                } label: { Text("Sair") }
            }
            
            
        }
    }
    
    private var header: some View {
        HStack(spacing: 12) {
            Text("Jogadores conectados")
                .font(.headline)
            Spacer()
            if viewModel.allReady && !viewModel.players.isEmpty {
                Text("Todos prontos ✅")
                    .font(.subheadline)
                    .foregroundStyle(.green)
            } else {
                Text("\(viewModel.players.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
    
    private var playersStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.players, id: \.gamePlayerID) { p in
                    let ready = viewModel.readyMap[p.gamePlayerID] ?? false
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .frame(width: 48, height: 48)
                                .overlay(Text(initials(of: p.displayName)).font(.headline))
                            
                            Circle()
                                .frame(width: 12, height: 12)
                                .foregroundStyle(ready ? .green : .gray)
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .offset(x: 18, y: 18)
                        }
                        .accessibilityHidden(true)
                        
                        Text(p.displayName)
                            .font(.caption)
                            .lineLimit(1)
                            .frame(width: 88)
                        
                        Text(ready ? "Ready" : "Not Ready")
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(ready ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                            .clipShape(Capsule())
                    }
                    .padding(6)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.vertical, 8)
        }
        .accessibilityLabel(Text("Lista de jogadores"))
    }
    
    private var chatArea: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(viewModel.messages.indices, id: \.self) { i in
                        Text(viewModel.messages[i])
                            .padding(8)
                            .background(Color.blue.opacity(0.18))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .id(i)
                    }
                }
                .padding()
            }
            .onChange(of: scrollTrigger) { _ in
                if let last = viewModel.messages.indices.last {
                    withAnimation { proxy.scrollTo(last, anchor: .bottom) }
                }
            }
        }
    }
    
    private var inputBar: some View {
        HStack(spacing: 8) {
            TextField("Digite sua mensagem...", text: $viewModel.typedMessage)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button("Enviar") {
                viewModel.sendMessage()
                scrollTrigger &+= 1
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.typedMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding()
    }
    
    private func initials(of name: String) -> String {
        let parts = name.split(separator: " ")
        let a = parts.first?.first.map(String.init) ?? ""
        let b = parts.dropFirst().first?.first.map(String.init) ?? ""
        return (a + b).uppercased()
    }
    
    private enum GradientState: Equatable {
        case initial
        case startDragging
        case midDragging
        case completed
    }
    
    private var currentGradientState: GradientState {
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
        else if dragProgress == 0{
            return.initial
        } else {
            return .startDragging
        }
    }
    
    // MARK: - Smooth Background Gradient
    private var smoothBackgroundGradient: LinearGradient {
        switch currentGradientState {
        case .initial:
            return LinearGradient(
                colors: [Color.darkRed, Color.lightRed],
                startPoint: .leading,
                endPoint: .trailing
            )
            
        case .startDragging:
            return LinearGradient(
                colors: [Color.darkRed, Color.darkGreen],
                startPoint: .leading,
                endPoint: .trailing
            )
            
        case .midDragging:
            return LinearGradient(
                colors: [Color.darkRed, Color.darkGreen, Color.lightGreen],
                startPoint: .leading,
                endPoint: .trailing
            )
            
        case .completed:
            return LinearGradient(
                colors: [Color.lightGreen, Color.darkGreen],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    // MARK: - Supporting Properties
    private var sliderText: String {
        switch currentGradientState {
        case .initial, .startDragging:
            return "ready?"
        case .midDragging:
            return dragProgress > 0.8 ? "ready!" : "ready?"
        case .completed:
            return "ready!"
        }
    }
    
    private var knobIcon: String {
        dragProgress > 0.8 ? "checkmark" : "chevron.right"
    }
    
    private var knobColor: Color {
        dragProgress > 0.8 ? .darkGreen : .darkRed
    }
}


