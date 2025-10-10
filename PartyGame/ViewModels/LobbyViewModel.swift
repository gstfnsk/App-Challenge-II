//
//  LobbyViewModel.swift
//  PartyGame
//
//  Created by Rafael Toneto on 10/09/25.
//

import Foundation
import SwiftUI
import Combine
import GameKit

final class LobbyViewModel: ObservableObject {

    struct ChatItem: Identifiable, Equatable {
        let id = UUID()
        let senderID: String
        let senderName: String
        let isLocal: Bool
        let text: String
    }

    struct PlayerRow: Identifiable, Equatable {
        let id: String
        let name: String
        let isMe: Bool
        let isReady: Bool
    }

    @Published var chat: [ChatItem] = []
    @Published var messages: [String] = []
    @Published var typedMessage: String = ""

    @Published var playerRows: [PlayerRow] = []
    @Published var isInMatch: Bool = false
    @Published var readyMap: [String: Bool] = [:]

    @Published var isSliderComplete: Bool = false

    @Published var avatarByID: [String: UIImage] = [:]
    func avatar(for id: String) -> UIImage? { avatarByID[id] }

    private let service: GameCenterServiceProtocol
    private var cancellables: Set<AnyCancellable> = []

    private var players: [GKPlayer] = []

    var localPlayerID: String { GKLocalPlayer.local.gamePlayerID }

    var isLocalReady: Bool { readyMap[localPlayerID] ?? false }
    var allReady: Bool {
        guard !playerRows.isEmpty else { return false }
        for row in playerRows where row.isReady == false { return false }
        return true
    }

    init(service: GameCenterServiceProtocol = GameCenterService.shared) {
        self.service = service

        self.players = service.gamePlayersSnapshot.map { $0.player }
        self.readyMap = service.readyMapSnapshot
        self.buildPlayerRows(from: players, ready: readyMap)
        self.loadAvatars(for: self.players)
        self.messages = service.messagesSnapshot
        self.isInMatch = service.isInMatchSnapshot

        Publishers.CombineLatest(service.gamePlayersPublisher, service.readyMapPublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] gamePlayers, ready in
                guard let self else { return }
                let gks = gamePlayers.map { $0.player }
                self.players = gks
                self.readyMap = ready
                self.buildPlayerRows(from: gks, ready: ready)
                self.loadAvatars(for: gks)
            }
            .store(in: &cancellables)

        service.messagesPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$messages)

        service.messagesPublisher
            .receive(on: DispatchQueue.main)
            .map { [weak self] raws in
                guard let self else { return [] }
                return raws.map(self.parseMessage)
            }
            .assign(to: &$chat)

        service.isInMatchPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$isInMatch)
    }

    func sendMessage() {
        let text = typedMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        service.sendMessage(text)
        typedMessage = ""
    }

    func leaveLobby() {
        service.leaveMatch()
    }

    func toggleReady() {
        service.toggleReady()
    }

    func markSliderComplete() {
        isSliderComplete = true
        toggleReady()
    }

    func markSliderIncomplete() {
        isSliderComplete = false
    }

    func resetAllPlayersReady() {
        service.resetReadyForAllPlayers()
    }

    private func buildPlayerRows(from gks: [GKPlayer], ready: [String: Bool]) {
        let meID = localPlayerID
        self.playerRows = gks.map {
            PlayerRow(
                id: $0.gamePlayerID,
                name: $0.displayName,
                isMe: $0.gamePlayerID == meID,
                isReady: ready[$0.gamePlayerID] ?? false
            )
        }
    }

    private func loadAvatars(for players: [GKPlayer]) {
        for p in players {
            p.loadPhoto(for: .small) { [weak self] img, _ in
                guard let self else { return }
                DispatchQueue.main.async {
                    self.avatarByID[p.gamePlayerID] = img
                }
            }
        }
    }

    private func parseMessage(_ raw: String) -> ChatItem {
        let meName = GKLocalPlayer.local.displayName
        let meID   = GKLocalPlayer.local.gamePlayerID

        if raw.hasPrefix("Você:") || raw.hasPrefix("You:") {
            let text = raw
                .replacingOccurrences(of: "Você:", with: "")
                .replacingOccurrences(of: "You:", with: "")
                .trimmingCharacters(in: .whitespaces)
            return ChatItem(senderID: meID, senderName: meName, isLocal: true, text: text)
        }

        if let idx = raw.firstIndex(of: ":") {
            let name = String(raw[..<idx])
            let text = raw[raw.index(after: idx)...].trimmingCharacters(in: .whitespaces)

            let id = players.first(where: { $0.displayName == name })?.gamePlayerID ?? ""
            return ChatItem(senderID: id, senderName: name, isLocal: name == meName, text: text)
        }

        return ChatItem(senderID: meID, senderName: meName, isLocal: true, text: raw)
    }
}
