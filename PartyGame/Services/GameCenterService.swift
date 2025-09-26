//
//  GameCenterService.swift
//  PartyGame
//
//  Consolidated + reviewed by ChatGPT
//

import SwiftUI
import GameKit

// MARK: - Helper para pegar rootViewController
extension UIApplication {
    var currentRootViewController: UIViewController? {
        return self.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
    }
}

private struct LobbyPacket: Codable {
    enum PacketType: String, Codable { case chat, ready }
    let type: PacketType
    let senderID: String
    let text: String?
    let ready: Bool?
    
    static func chat(senderID: String, text: String) -> LobbyPacket {
        .init(type: .chat, senderID: senderID, text: text, ready: nil)
    }
    static func ready(senderID: String, ready: Bool) -> LobbyPacket {
        .init(type: .ready, senderID: senderID, text: nil, ready: ready)
    }
}

struct SubmissionPayload: Codable {
    let type: String
    let submission: PlayerSubmission
}

// NOTE: Player, PlayerSubmission, ImageSubmission, Phrases must exist elsewhere in your project.
// This file assumes those types are defined like in your original project.

class GameCenterService: NSObject, ObservableObject {
    
    static let shared = GameCenterService()
    
    // MARK: - Published state
    @Published var isAuthenticated = false
    @Published var isInMatch = false
    @Published var gamePlayers: [Player] = []
    @Published var readyMap: [String: Bool] = [:]
    @Published var messages: [String] = []
    @Published var isSinglePlayer = false
    @Published var totalRounds: Int = 10
    @Published var currentRound: Int = 1
    @Published var phrases: [String] = []
    
    @Published var currentPhrase = ""
    @Published var phraseLeaderID: String? = nil
    @Published var isWaitingForPhrase = false
    var localPhraseChoices: [String: [String]] = [:]
    
    @Published var playerSubmissions: [PlayerSubmission] = []
    @Published var timerStart: Date? = nil
    
    @Published var isPhraseSubmittedByAnyPlayer: Bool = false
    @Published var submittedPhrasesByPlayer: [String: String] = [:] // playerID -> phrase
    
    // Networking / match
    var match: GKMatch?
    private var pendingInvite: GKInvite?
    private var pendingPlayersToInvite: [GKPlayer]?
    
    // Derived
    private var expectedPlayersCount: Int {
        if isSinglePlayer { return 1 }
        let ids = Set(([GKLocalPlayer.local] + (match?.players ?? [])).map { $0.gamePlayerID })
        return ids.count
    }
    
    // Convenience
    private var localPlayerID: String { GKLocalPlayer.local.gamePlayerID }
    
    override init() {
        super.init()
        authenticatePlayer()
        setupAppStateObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - App state observer
    private func setupAppStateObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc private func appDidBecomeActive() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.processPendingInvite()
        }
    }
    
    // MARK: - Authentication
    private func authenticatePlayer() {
        GKLocalPlayer.local.authenticateHandler = { vc, error in
            if let vc = vc {
                UIApplication.shared.currentRootViewController?.present(vc, animated: true)
            } else if GKLocalPlayer.local.isAuthenticated {
                print("✅ Jogador autenticado: \(GKLocalPlayer.local.displayName)")
                DispatchQueue.main.async { self.isAuthenticated = true }
                GKLocalPlayer.local.register(self)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.processPendingInvite()
                }
            } else {
                print("❌ Falha ao autenticar: \(String(describing: error))")
                DispatchQueue.main.async { self.isAuthenticated = false }
            }
        }
    }
    
    // MARK: - Phase start scheduling
    func schedulePhaseStart(delay: TimeInterval = 1) {
        let target = Date().addingTimeInterval(delay)
        timerStart = target
        broadcastPhaseStart(target)
    }
    
    private func broadcastPhaseStart(_ date: Date) {
        guard let match else { return }
        let payload: [String: Any] = [
            "type": "phaseStart",
            "date": date.timeIntervalSince1970
        ]
        do {
            let data = try JSONSerialization.data(withJSONObject: payload)
            try match.sendData(toAllPlayers: data, with: .reliable)
        } catch {
            print("❌ Erro ao enviar phaseStart: \(error)")
        }
    }
    
    func handleReceivedData(_ data: Data) {
        guard
            let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let type = dict["type"] as? String
        else { return }
        
        if type == "phaseStart", let ts = dict["date"] as? TimeInterval {
            timerStart = Date(timeIntervalSince1970: ts)
        }
    }
    
    // MARK: - Phrase submission (local & broadcast)
    func submitPhrase(phrase: String) {
        let playerID = localPlayerID
        // Evita sobrescrever caso já tenha submetido
        guard submittedPhrasesByPlayer[playerID] == nil else {
            print("⏭️ Ignorando submissão repetida de \(playerID)")
            return
        }
        
        // Registra localmente
        submittedPhrasesByPlayer[playerID] = phrase
        if !phrases.contains(phrase) { phrases.append(phrase) }
        
        // Broadcast
        guard let match else { return }
        let payload: [String: Any] = [
            "type": "newPhrase",
            "phrase": phrase
        ]
        do {
            let data = try JSONSerialization.data(withJSONObject: payload)
            try match.sendData(toAllPlayers: data, with: .reliable)
        } catch {
            print("❌ Erro ao enviar phrase: \(error)")
        }
        
        // Trigger: tentar selecionar (reintroduzido)
        trySelectPhraseIfReady()
    }
    
    // Fallbacks / auto-submit logic
    func ensureAllPlayersSubmittedFallback() {
        // Para cada jogador que ainda não submeteu, tenta pegar uma frase do pool local e submeter
        for player in gamePlayers {
            let playerID = player.player.gamePlayerID
            if submittedPhrasesByPlayer[playerID] != nil { continue }
            
            if let randomPhrase = localPhraseChoices[playerID]?.randomElement() {
                print("⚠️ Auto-submit forçado para \(player.player.displayName): \(randomPhrase)")
                submittedPhrasesByPlayer[playerID] = randomPhrase
                if !phrases.contains(randomPhrase) { phrases.append(randomPhrase) }
                submitPhrase(phrase: randomPhrase)
            } else if let backup = Phrases.all.randomElement()?.text {
                print("⚡ Fallback global para \(player.player.displayName): \(backup)")
                submittedPhrasesByPlayer[playerID] = backup
                if !phrases.contains(backup) { phrases.append(backup) }
                submitPhrase(phrase: backup)
            }
        }
    }
    
    // Alternate auto-submit that was present historically (kept but not used by default)
    func autoSubmitMissingPhrases() {
        let submittedPlayerIDs = Set(playerSubmissions.map { $0.playerID })
        for player in gamePlayers {
            let playerID = player.player.gamePlayerID
            if !submittedPlayerIDs.contains(playerID) {
                if let randomPhrase = Phrases.all.randomElement() {
                    print("⚡ Auto-submit para jogador \(player.player.displayName): \(randomPhrase)")
                    submitPhrase(phrase: randomPhrase.text)
                }
            }
        }
    }
    
    // MARK: - Leader election & phrase selection
    private func electPhraseLeader() -> String? {
        guard !gamePlayers.isEmpty else { return nil }
        let sortedPlayers = gamePlayers.sorted { $0.player.gamePlayerID < $1.player.gamePlayerID }
        return sortedPlayers.first?.player.gamePlayerID
    }
    
    func initiatePhraseSelection() {
        // Garante que todos tenham uma frase (fallback)
        ensureAllPlayersSubmittedFallback()
        
        if Phrases.all.isEmpty {
            print("⚠️ As frases disponíveis estão vazias em Phrases.all!")
            return
        }
        
        guard currentPhrase.isEmpty && phraseLeaderID == nil else {
            print("⚠️ Seleção de frase já em andamento ou frase já selecionada")
            return
        }
        
        let localID = localPlayerID
        guard let leaderID = electPhraseLeader() else {
            print("❌ Não foi possível eleger um líder")
            return
        }
        
        phraseLeaderID = leaderID
        
        if isSinglePlayer {
            selectRandomPhrase()
        } else {
            broadcastPhraseLeader(leaderID)
            if localID != leaderID {
                isWaitingForPhrase = true
            }
            DispatchQueue.main.async { self.trySelectPhraseIfReady() }
        }
    }
    
    private func selectRandomPhrase() {
        if !currentPhrase.isEmpty {
            print("⚠️ Seleção já foi feita: \(currentPhrase)")
            return
        }
        guard !phrases.isEmpty else {
            print("❌ Nenhuma frase disponível para seleção")
            return
        }
        if let selected = phrases.randomElement() {
            currentPhrase = selected
            print("🎯 Líder selecionou a frase: \(selected)")
            broadcastSelectedPhrase(selected)
        }
    }
    
    private func broadcastPhraseLeader(_ leaderID: String) {
        guard let match = match else { return }
        let payload: [String: Any] = [
            "type": "PhraseLeader",
            "leaderID": leaderID
        ]
        do {
            let data = try JSONSerialization.data(withJSONObject: payload)
            try match.sendData(toAllPlayers: data, with: .reliable)
            print("📡 Líder da frase eleito: \(leaderID)")
        } catch {
            print("❌ Erro ao enviar eleição do líder: \(error)")
        }
    }
    
    private func broadcastSelectedPhrase(_ phrase: String) {
        guard let match = match else { return }
        let payload: [String: Any] = [
            "type": "SelectedPhrase",
            "currentPhrase": phrase
        ]
        do {
            let data = try JSONSerialization.data(withJSONObject: payload)
            try match.sendData(toAllPlayers: data, with: .reliable)
            print("📡 Frase selecionada enviada: \(phrase)")
        } catch {
            print("❌ Erro ao enviar frase selecionada: \(error)")
        }
    }
    
    // Legacy compat wrapper
    func setCurrentRandomPhrase() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.initiatePhraseSelection()
        }
    }
    
    func getCurrentRandomPhrase() -> String {
        return self.currentPhrase
    }
    
    // Check if all players submitted images
    func haveAllPlayersSubmittedImage() -> Bool {
        print(playerSubmissions)
        return ((gamePlayers.count == playerSubmissions.count && gamePlayers.count != 0) ? true : false)
    }
    
    // MARK: - Image submission
    func addSubmission(playerID: String, phrase: String, image: ImageSubmission) {
        let submission = PlayerSubmission(playerID: playerID, phrase: phrase, imageSubmission: image, votes: 0)
        playerSubmissions.append(submission)
        
        guard let match else { return }
        do {
            let payload = SubmissionPayload(type: "newImage", submission: submission)
            let data = try JSONEncoder().encode(payload)
            try match.sendData(toAllPlayers: data, with: .reliable)
        } catch {
            print("❌ Erro ao enviar submission: \(error)")
        }
        
        print("Nova submissão adicionada:", submission)
        print("todas images: \(playerSubmissions)")
    }
    
    func getSubmittedImages() -> [PlayerSubmission] {
        return self.playerSubmissions
    }
    
    func haveAllPlayersSubmittedPhrase() -> Bool {
        print("\(phrases)")
        return (gamePlayers.count == submittedPhrasesByPlayer.count && gamePlayers.count != 0)
    }
    
    // Rounds
    var maxRounds: Int { gamePlayers.count }
    
    func goToNextRound() {
        if currentRound < maxRounds {
            currentRound += 1
            resetPhraseState()
        }
    }
    
    private func resetPhraseState() {
        currentPhrase = ""
        phraseLeaderID = nil
        isWaitingForPhrase = false
        submittedPhrasesByPlayer.removeAll()
        phrases.removeAll()
    }
    
    // MARK: - Helper: trySelectPhraseIfReady (reintroduced & robust)
    private func trySelectPhraseIfReady() {
        // Only proceed if no currentPhrase and there's a leader
        guard currentPhrase.isEmpty else { return }
        guard let leaderID = phraseLeaderID else { return }
        
        // Determine expected participant count
        let expected = expectedPlayersCount
        guard expected > 0 else { return }
        
        // Have all players submitted? Use submittedPhrasesByPlayer as source of truth.
        let haveAll = submittedPhrasesByPlayer.count >= expected
        guard haveAll else { return }
        
        // If this device is the leader -> select and broadcast
        if localPlayerID == leaderID {
            selectRandomPhrase()
        } else {
            DispatchQueue.main.async { self.isWaitingForPhrase = true }
        }
    }
    
    // MARK: - Player / match management
    private func refreshPlayers() {
        var everyone: [GKPlayer] = [GKLocalPlayer.local as GKPlayer]
        if let remotes = match?.players { everyone.append(contentsOf: remotes) }
        DispatchQueue.main.async {
            // replace gamePlayers to avoid duplicates
            self.gamePlayers = everyone.map { Player(player: $0) }
            
            var map = self.readyMap
            for p in everyone {
                if map[p.gamePlayerID] == nil { map[p.gamePlayerID] = false }
            }
            self.readyMap = map
        }
    }
    
    func leaveMatch() {
        if !isSinglePlayer {
            match?.disconnect()
        }
        
        match = nil
        DispatchQueue.main.async {
            self.isInMatch = false
            self.isSinglePlayer = false
            self.gamePlayers.removeAll()
            self.readyMap.removeAll()
            self.messages.removeAll()
            self.resetPhraseState()
        }
    }
    
    // MARK: - Invitations & match creation
    func processPendingInvite() {
        if let invite = pendingInvite {
            print("📩 Processando convite pendente de \(invite.sender.displayName)")
            pendingInvite = nil
            acceptInvite(invite)
        } else if let players = pendingPlayersToInvite {
            print("📩 Processando solicitação de partida pendente para \(players.count) jogadores")
            pendingPlayersToInvite = nil
            acceptMatchRequest(with: players)
        } else {
            print("ℹ️ Nenhum convite pendente para processar")
        }
    }
    
    private func acceptInvite(_ invite: GKInvite) {
        print("📩 Processando convite de \(invite.sender.displayName)")
        if let vc = GKMatchmakerViewController(invite: invite) {
            vc.matchmakerDelegate = self
            UIApplication.shared.currentRootViewController?.present(vc, animated: true)
        }
    }
    
    private func acceptMatchRequest(with players: [GKPlayer]) {
        print("📩 Processando solicitação de partida para \(players.count) jogadores")
        let request = GKMatchRequest()
        request.recipients = players
        request.minPlayers = 2
        request.maxPlayers = 4
        if let vc = GKMatchmakerViewController(matchRequest: request) {
            vc.matchmakerDelegate = self
            UIApplication.shared.currentRootViewController?.present(vc, animated: true)
        }
    }
    
    func startMatchmaking(minPlayers: Int = 1, maxPlayers: Int = 4, singlePlayerMode: Bool = false) {
        guard isAuthenticated else {
            print("⚠️ Usuário não está autenticado")
            return
        }
        if singlePlayerMode || minPlayers == 1 {
            createSinglePlayerMatch()
            return
        }
        let request = GKMatchRequest()
        request.minPlayers = minPlayers
        request.maxPlayers = maxPlayers
        if let vc = GKMatchmakerViewController(matchRequest: request) {
            vc.matchmakerDelegate = self
            UIApplication.shared.currentRootViewController?.present(vc, animated: true)
        }
    }
    
    private func createSinglePlayerMatch() {
        print("✅ Starting single player match")
        DispatchQueue.main.async {
            self.isInMatch = true
            self.isSinglePlayer = true
            self.match = nil
            self.gamePlayers = [Player(player: GKLocalPlayer.local)]
            self.readyMap = [GKLocalPlayer.local.gamePlayerID: false]
            self.messages = ["Welcome to single player mode!"]
            self.phrases = []
            self.resetPhraseState()
        }
    }
    
    // MARK: - Chat / ready
    func sendMessage(_ text: String) {
        if isSinglePlayer {
            DispatchQueue.main.async { self.messages.append("You: \(text)") }
            return
        }
        guard let match = match else {
            print("⚠️ Nenhuma partida ativa")
            return
        }
        let senderID = localPlayerID
        let packet = LobbyPacket.chat(senderID: senderID, text: text)
        do {
            let data = try JSONEncoder().encode(packet)
            try match.sendData(toAllPlayers: data, with: .reliable)
            DispatchQueue.main.async { self.messages.append("Você: \(text)") }
        } catch {
            print("❌ Erro ao enviar mensagem: \(error)")
        }
    }
    
    func toggleReady() {
        let id = localPlayerID
        let newValue = !(readyMap[id] ?? false)
        DispatchQueue.main.async { self.readyMap[id] = newValue }
        if isSinglePlayer { return }
        guard let match = match else { return }
        let packet = LobbyPacket.ready(senderID: id, ready: newValue)
        do {
            let data = try JSONEncoder().encode(packet)
            try match.sendData(toAllPlayers: data, with: .reliable)
        } catch {
            print("❌ Erro ao enviar READY: \(error)")
        }
    }
    
    private func setReady(_ value: Bool) {
        let id = localPlayerID
        DispatchQueue.main.async { self.readyMap[id] = value }
        guard let match = match else { return }
        let packet = LobbyPacket.ready(senderID: id, ready: value)
        do {
            let data = try JSONEncoder().encode(packet)
            try match.sendData(toAllPlayers: data, with: .reliable)
        } catch {
            print("❌ Erro ao enviar READY: \(error)")
        }
    }
}

// MARK: - Delegates
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
        // Primeiro: tentar decodificar como LobbyPacket (mensagens de lobby)
        if let packet = try? JSONDecoder().decode(LobbyPacket.self, from: data) {
            DispatchQueue.main.async {
                switch packet.type {
                case .chat:
                    if let text = packet.text {
                        self.messages.append("\(player.displayName): \(text)")
                    }
                case .ready:
                    let value = packet.ready ?? false
                    self.readyMap[player.gamePlayerID] = value
                }
            }
            return
        }
        
        // Segundo: tentar decodificar como SubmissionPayload (image submissions)
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
            // continue: not returning because some older messages may be JSON dicionary-like
        }
        
        // Terceiro: dicionário genérico
        guard
            let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let type = (dict["type"] as? String)?.lowercased()
        else {
            // fallback para texto simples
            if let text = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.messages.append("\(player.displayName): \(text)")
                }
            }
            return
        }
        
        switch type {
        case "phraseleader":
            if let leaderID = dict["leaderID"] as? String {
                DispatchQueue.main.async {
                    self.phraseLeaderID = leaderID
                    print("📡 Líder da frase recebido: \(leaderID)")
                    self.trySelectPhraseIfReady()
                }
            }
        case "selectedphrase":
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
        case "newphrase":
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
        case "phasestart":
            if let ts = dict["date"] as? TimeInterval {
                DispatchQueue.main.async { self.timerStart = Date(timeIntervalSince1970: ts) }
            }
        default:
            print("⚠️ Tipo de mensagem desconhecido: \(type)")
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

// MARK: - Listener de convites
extension GameCenterService: GKLocalPlayerListener {
    func player(_ player: GKPlayer, didAccept invite: GKInvite) {
        print("📩 Convite recebido de \(invite.sender.displayName)")
        pendingInvite = invite
        if UIApplication.shared.applicationState == .active {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.processPendingInvite() }
        }
    }
    
    func player(_ player: GKPlayer, didRequestMatchWithRecipients recipientPlayers: [GKPlayer]) {
        print("📩 Solicitação de partida recebida para \(recipientPlayers.count) jogadores")
        pendingPlayersToInvite = recipientPlayers
        if UIApplication.shared.applicationState == .active {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { self.processPendingInvite() }
        }
    }
}
