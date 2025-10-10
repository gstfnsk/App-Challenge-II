//
//  LobbyViewModel.swift
//  PartyGame
//
//  Created by Rafael Toneto on 10/09/25.
//

import Foundation
import SwiftUI
import GameKit

@Observable
final class LobbyViewModel {

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

    var chat: [ChatItem] = []
    var messages: [String] = []
    var typedMessage: String = ""

    var playerRows: [PlayerRow] = []
    var isInMatch: Bool = false
    var readyMap: [String: Bool] = [:]

    var isSliderComplete: Bool = false

    var avatarByID: [String: UIImage] = [:]
    func avatar(for id: String) -> UIImage? { avatarByID[id] }

    private let service = GameCenterService.shared
    private var observationTimer: Timer?

    private var players: [GKPlayer] = []

    var localPlayerID: String { GKLocalPlayer.local.gamePlayerID }

    var isLocalReady: Bool { readyMap[localPlayerID] ?? false }
    var allReady: Bool {
        guard !playerRows.isEmpty else { return false }
        for row in playerRows where row.isReady == false { return false }
        return true
    }

    init() {
        self.players = service.gamePlayers.map { $0.player as! GKPlayer }
        self.buildPlayerRows(from: players, ready: service.readyMap)
        self.loadAvatars(for: self.players)

        // 🔥 Com @Observable, use withObservationTracking ou Timer
        startObservingService()
    }
    
    private func startObservingService() {
        // Opção 1: Timer (mais simples e confiável para multiplayer)
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.syncFromService()
        }
    }
    
    deinit {
        observationTimer?.invalidate()
    }
    
    private func syncFromService() {
        let gks = service.gamePlayers.map { $0.player as! GKPlayer }
        self.players = gks
        self.readyMap = service.readyMap[.lobby] ?? [:]
        self.buildPlayerRows(from: gks, ready: service.readyMap)
        self.loadAvatars(for: gks)
        
        // Atualiza mensagens
        let newMessages = service.messages
        if self.messages != newMessages {
            self.messages = newMessages
            self.chat = newMessages.map(self.parseMessage)
        }
        
        // Atualiza status da partida
        self.isInMatch = service.isInMatch
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
        service.setReady(gamePhase: .lobby)
        
        // 🔥 Atualização local imediata para feedback instantâneo
        var localMap = readyMap
        localMap[localPlayerID] = true
        readyMap = localMap
        
        // A atualização do broadcast virá via Combine depois
    }

    func markSliderComplete() {
        isSliderComplete = true
        toggleReady()
    }

    func markSliderIncomplete() {
        isSliderComplete = false
    }

    func resetAllPlayersReady() {
        service.resetReadyForAllPlayers(gamePhase: .lobby)
    }

    private func buildPlayerRows(from gks: [GKPlayer], ready: [GamePhase:[String: Bool]]) {
        let meID = localPlayerID
        self.playerRows = gks.map {
            PlayerRow(
                id: $0.gamePlayerID,
                name: $0.displayName,
                isMe: $0.gamePlayerID == meID,
                isReady: (ready[.lobby] ?? [:])[$0.gamePlayerID] ?? false
            )
        }
    }

    private func loadAvatars(for players: [GKPlayer]) {
        for p in players {
            p.loadPhoto(for: .small) { [weak self] img, _ in
                guard let self else { return }
                // 🔥 Com @Observable, não precisa DispatchQueue.main.async
                // mas mantemos por segurança com API de callback
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
