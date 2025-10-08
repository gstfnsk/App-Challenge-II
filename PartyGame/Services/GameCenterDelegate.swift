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
            
            var map: [GamePhase: [String: Bool]] = [:]
            
            for phase in GamePhase.allCases {
                var phaseMap: [String: Bool] = [:]
                
                phaseMap[localID] = false
                
                for p in match.players {
                    phaseMap[p.gamePlayerID] = false
                }
                
                map[phase] = phaseMap
            }
            
            self.phrases = []
            self.readyMap = map
        }
        
//        sendMessage("Olá, galera!")
    }
    
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        
        guard
            let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let type = dict["type"] as? String
        else { return }
        
        switch type {
        case "newPhrase":
            if let phrase = dict["phrase"] as? String {
                let senderID = player.gamePlayerID
                DispatchQueue.main.async {
                    if !self.phrases.contains(phrase) {
                        self.phrases.append(phrase)
                        print("📡 Frase '\(phrase)' recebida de \(player.displayName)")
                    }
                    if self.submittedPhrasesByPlayer[senderID] == nil {
                        self.submittedPhrasesByPlayer[senderID] = phrase
                        print("🔄 Atualizando submissão do jogador \(player.displayName): \(phrase)")
                    } else {
                        print("⏭️ Jogador \(player.displayName) já tinha submetido uma frase")
                    }
                    // reintroduzido: tentar seleção quando recebemos uma frase
                    self.trySelectPhraseIfReady()
                }
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
            
        case "phasestart":
            if let ts = dict["date"] as? TimeInterval {
                //DispatchQueue.main.async { self.timerStart = Date(timeIntervalSince1970: ts) }
            }
            
        default:
            break
        }
        
        if let votePacket = try? JSONDecoder().decode(VoteSubmissionPayload.self, from: data) {
            switch votePacket.type {
            case "newVote":
                let vote = votePacket.submission
                print("📡 voto recebido de \(vote.from)")
                    DispatchQueue.main.async {
                        self.storeVote(vote: vote)
                    }
            default:
                break
            }
        }
        
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
                // Unwrap the optional gamePhase and safely update readyMap
                if let phase = packet.gamePhase {
                    DispatchQueue.main.async {
                        var phaseMap = self.readyMap[phase] ?? [:]
                        phaseMap[player.gamePlayerID] = true
                        self.readyMap[phase] = phaseMap
                    }
                } else {
                    print("⚠️ Received .ready without a gamePhase")
                }
                
            }
        } else if let text = String(data: data, encoding: .utf8) {
            DispatchQueue.main.async {
                self.messages.append("\(player.displayName): \(text)")
            }
        }
    }
    
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
