//
//  File.swift
//  Pickture
//
//  Created by Fernando Sulzbach on 25/09/25.
//
import SwiftUI
import GameKit

extension GameCenterService: GKMatchmakerViewControllerDelegate, GKMatchDelegate {
    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        viewController.dismiss(animated: true)
        print("❌ Matchmaking cancelado")
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController,
                                  didFailWithError error: Error) {
        viewController.dismiss(animated: true)
        print("❌ Erro no matchmaking: \(error.localizedDescription)")
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController,
                                  didFind match: GKMatch) {
        viewController.dismiss(animated: true)
        self.match = match
        match.delegate = self
        print("✅ Match encontrado com \(match.players.count) jogadores")
        
        refreshPlayers()
        let localID = GKLocalPlayer.local.gamePlayerID
        DispatchQueue.main.async {
            self.isInMatch = true
            var map: [String: Bool] = [:]
            map[localID] = false
            for p in match.players { map[p.gamePlayerID] = false }
            self.phrases = []
            self.readyMap = map
        }
        
        sendMessage("Olá, galera!")
    }
    
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        
        guard
            let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let type = dict["type"] as? String
        else { return }
        
        switch type {
        case "newPhrase":
            if let phrase = dict["phrase"] as? String {
                print("frase adicionada Delegate")
                phrases.append(phrase)
                self.trySelectPhraseIfReady()
            }
        case "PhraseLeader":
            if let leaderID = dict["leaderID"] as? String {
                DispatchQueue.main.async {
                    self.phraseLeaderID = leaderID
                    print("📡 Líder da frase recebido: \(leaderID)")
                    self.trySelectPhraseIfReady()
                }
            }
        case "SelectedPhrase":
            if let phrase = dict["currentPhrase"] as? String {
                DispatchQueue.main.async {
                    if self.currentPhrase.isEmpty {
                        self.currentPhrase = phrase
                        self.isWaitingForPhrase = false
                        print("📡 Frase selecionada recebida: \(phrase)")
                    } else {
                        print("⚠️ Frase já estava definida: \(self.currentPhrase)")
                    }
                }
            }
        case "CleanPlayerSubmissions":
            DispatchQueue.main.async {
                self.cleanPlayerSubmissions(broadcast: false)
                print("📡 PlayerSubmissions limpo com sucesso: \(self.playerSubmissions)")
            }
        default:
            break
        }
        
//        guard
//            let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
//            let type = dict["type"] as? String
//        else { return }
//        
//        switch type {
//        case "newPhrase":
//            if let phrase = dict["phrase"] as? String {
//                print("frase adicionada Delegate")
//                phrases.append(phrase)
//                self.trySelectPhraseIfReady()
//            }
//            
//        default:
//            break
//        }
        
        if let payload = try? JSONDecoder().decode(SubmissionPayload.self, from: data) {
            switch payload.type {
            case "newImage":
                let submission = payload.submission
                DispatchQueue.main.async {
                    self.playerSubmissions.append(submission)
                    print("Nova submissão recebida e adicionada: \(submission)")
                    print("Printar todos jogadores: \(self.gamePlayers)")
                }
            default:
                break
            }
        }
        
        if let packet = try? JSONDecoder().decode(LobbyPacket.self, from: data) {
            switch packet.type {
            case .chat:
                if let text = packet.text {
                    DispatchQueue.main.async {
                        self.messages.append("\(player.displayName): \(text)")
                    }
                }
            case .ready:
                let value = packet.ready ?? false
                DispatchQueue.main.async {
                    self.readyMap[player.gamePlayerID] = value
                }
            }
        } else if let text = String(data: data, encoding: .utf8) {
            DispatchQueue.main.async {
                self.messages.append("\(player.displayName): \(text)")
            }
        }
    }
    
    /*func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        
        // MARK: - Try LobbyPacket First (chat and ready messages)
        if let packet = try? JSONDecoder().decode(LobbyPacket.self, from: data) {
            switch packet.type {
            case .chat:
                guard let text = packet.text else {
                    print("❌ Chat packet missing text")
                    return
                }
                DispatchQueue.main.async {
                    self.messages.append("\(player.displayName): \(text)")
                }
                
            case .ready:
                let isReady = packet.ready ?? false
                DispatchQueue.main.async {
                    self.readyMap[player.gamePlayerID] = isReady
                    print("📡 \(player.displayName) está ready: \(isReady)")
                }
            }
            return // Exit early if we handled a lobby packet
        }
        
        // MARK: - Try SubmissionPayload Second
        if let payload = try? JSONDecoder().decode(SubmissionPayload.self, from: data) {
            switch payload.type {
            case "newImage":
                DispatchQueue.main.async {
                    self.playerSubmissions.append(payload.submission)
                    print("📡 Nova submissão recebida de \(player.displayName): \(payload.submission)")
                }
                
            default:
                print("⚠️ Unhandled submission type: \(payload.type)")
            }
            return // Exit early if we handled a submission payload
        }
        
        // MARK: - Try JSON Dictionary (custom game messages)
        if let jsonDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let type = jsonDict["type"] as? String {
            
            switch type {
            case "PhraseLeader":
                guard let leaderID = jsonDict["leaderID"] as? String else {
                    print("❌ Invalid PhraseLeader message format")
                    return
                }
                DispatchQueue.main.async {
                    self.phraseLeaderID = leaderID
                    print("📡 Líder da frase recebido: \(leaderID)")
                    self.trySelectPhraseIfReady()
                }
                
            case "SelectedPhrase":
                guard let phrase = jsonDict["currentPhrase"] as? String else {
                    print("❌ Invalid SelectedPhrase message format")
                    return
                }
                DispatchQueue.main.async {
                    if self.currentPhrase.isEmpty {
                        self.currentPhrase = phrase
                        self.isWaitingForPhrase = false
                        print("📡 Frase selecionada recebida: \(phrase)")
                    } else {
                        print("⚠️ Frase já estava definida: \(self.currentPhrase)")
                    }
                }
                
            case "newPhrase":
                guard let phrase = jsonDict["phrase"] as? String else {
                    print("❌ Invalid newPhrase message format")
                    return
                }
                DispatchQueue.main.async {
                    print("📡 Nova frase recebida: \(phrase)")
                    self.phrases.append(phrase)
                    self.trySelectPhraseIfReady()
                }
                
            case "phaseStart":
                guard let timestamp = jsonDict["date"] as? TimeInterval else {
                    print("❌ Invalid phaseStart message format")
                    return
                }
                DispatchQueue.main.async {
                    self.timerStart = Date(timeIntervalSince1970: timestamp)
                    print("📡 Phase start recebido: \(self.timerStart?.description ?? "nil")")
                }
                
            case "CleanPlayerSubmissions":
                DispatchQueue.main.async {
                    self.cleanPlayerSubmissions(broadcast: false)
                    print("📡 PlayerSubmissions limpo com sucesso: \(self.playerSubmissions)")
                }
                
            default:
                print("⚠️ Unhandled JSON message type: \(type)")
            }
            
            return // Exit early if we handled a JSON message
        }
        
        // MARK: - Try SubmissionPayload
        if let payload = try? JSONDecoder().decode(SubmissionPayload.self, from: data) {
            switch payload.type {
            case "newImage":
                DispatchQueue.main.async {
                    self.playerSubmissions.append(payload.submission)
                    print("📡 Nova submissão recebida de \(player.displayName): \(payload.submission)")
                }
                
            default:
                print("⚠️ Unhandled submission type: \(payload.type)")
            }
            
            return // Exit early if we handled a submission payload
        }
        
        // MARK: - Try Simple Dictionary (for CleanPlayerSubmissions fallback)
        if let simpleDict = try? JSONDecoder().decode([String: String].self, from: data),
           simpleDict["type"] == "CleanPlayerSubmissions" {
            
            DispatchQueue.main.async {
                self.cleanPlayerSubmissions(broadcast: false)
                print("📡 PlayerSubmissions limpo com sucesso (fallback): \(self.playerSubmissions)")
            }
            
            return // Exit early if we handled clean submissions
        }
        
        // MARK: - Try LobbyPacket
        if let packet = try? JSONDecoder().decode(LobbyPacket.self, from: data) {
            switch packet.type {
            case .chat:
                guard let text = packet.text else {
                    print("❌ Chat packet missing text")
                    return
                }
                DispatchQueue.main.async {
                    self.messages.append("\(player.displayName): \(text)")
                }
                
            case .ready:
                let isReady = packet.ready ?? false
                DispatchQueue.main.async {
                    self.readyMap[player.gamePlayerID] = isReady
                    print("📡 \(player.displayName) está ready: \(isReady)")
                }
            }
            
            return // Exit early if we handled a lobby packet
        }
        
        // MARK: - Fallback: Try Plain Text
        if let text = String(data: data, encoding: .utf8) {
            DispatchQueue.main.async {
                self.messages.append("\(player.displayName): \(text)")
                print("📡 Mensagem de texto recebida de \(player.displayName): \(text)")
            }
            
            return
        }
        
        // MARK: - Unrecognized Data
        print("⚠️ Received unrecognized data format from \(player.displayName)")
        print("📊 Data size: \(data.count) bytes")
    }*/
    
    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        switch state {
        case .connected:
            print("✅ \(player.displayName) conectado")
            refreshPlayers()
        case .disconnected:
            print("❌ \(player.displayName) desconectado")
            refreshPlayers()
        default:
            print("⚠️ Estado desconhecido para \(player.displayName)")
        }
    }
    
    func match(_ match: GKMatch, didFailWithError error: Error?) {
        print("❌ Erro no match: \(error?.localizedDescription ?? "desconhecido")")
        leaveMatch()
    }
    
}
