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

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            playersStrip
                .padding(.horizontal)
                .padding(.top, 8)
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

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.toggleReady()
                } label: {
                    Text(viewModel.isLocalReady ? "Cancelar" : "Ready")
                }
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
}
