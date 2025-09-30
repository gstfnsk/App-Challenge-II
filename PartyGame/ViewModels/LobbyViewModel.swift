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

    @Published var chat: [ChatItem] = []
    @Published var messages: [String] = []
    @Published var typedMessage: String = ""

    @Published var players: [GKPlayer] = []
    @Published var isInMatch: Bool = false
    @Published var readyMap: [String: Bool] = [:]

    @Published var isSliderComplete: Bool = false

    @Published var avatarByID: [String: UIImage] = [:]
    func avatar(for id: String) -> UIImage? { avatarByID[id] }

    private let service = GameCenterService.shared
    private var cancellables: Set<AnyCancellable> = []

    init() {
        self.players = service.gamePlayers.map { $0.player }
        self.loadAvatars(for: self.players)

        service.$gamePlayers
            .receive(on: DispatchQueue.main)
            .map { $0.map { $0.player } }
            .sink { [weak self] gks in
                self?.players = gks
                self?.loadAvatars(for: gks)
            }
            .store(in: &cancellables)

        service.$messages
            .receive(on: DispatchQueue.main)
            .assign(to: &$messages)

        service.$messages
            .receive(on: DispatchQueue.main)
            .map { [weak self] raws in
                guard let self else { return [] }
                return raws.map(self.parseMessage)
            }
            .assign(to: &$chat)

        service.$isInMatch
            .receive(on: DispatchQueue.main)
            .assign(to: &$isInMatch)

        service.$readyMap
            .receive(on: DispatchQueue.main)
            .assign(to: &$readyMap)
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

    var localPlayerID: String { GKLocalPlayer.local.gamePlayerID }
    var isLocalReady: Bool { readyMap[localPlayerID] ?? false }
    var allReady: Bool {
        guard !players.isEmpty else { return false }
        for p in players {
            if readyMap[p.gamePlayerID] != true { return false }
        }
        return true
    }

    func resetAllPlayersReady() {
        service.resetReadyForAllPlayers()
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
