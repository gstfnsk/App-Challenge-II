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

// MARK: - Game Center Helper
class GameCenterService: NSObject, ObservableObject {
    
    static let shared = GameCenterService()
    
    @Published var isAuthenticated = false
    @Published var isInMatch = false
    @Published var players: [GKPlayer] = []
    @Published var readyMap: [String: Bool] = [:]
    @Published var messages: [String] = []
    @Published var isSinglePlayer = false
    @Published var game: Game?
    @Published var imageSubmissions: [ImageSubmission] = []
    
    var match: GKMatch?
    private var pendingInvite: GKInvite?
    private var pendingPlayersToInvite: [GKPlayer]?
    
    override init() {
        super.init()
        authenticatePlayer()
        setupAppStateObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Observar mudanças no estado do app
    private func setupAppStateObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc private func appDidBecomeActive() {
        // Quando o app se torna ativo, verificar se há convites pendentes
        // Isso é importante quando o app é aberto através de um convite
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.processPendingInvite()
        }
    }
    
    // Autenticação
    private func authenticatePlayer() {
        GKLocalPlayer.local.authenticateHandler = { vc, error in
            if let vc = vc {
                // Apresenta a tela de login do Game Center
                UIApplication.shared.currentRootViewController?.present(vc, animated: true)
            } else if GKLocalPlayer.local.isAuthenticated {
                print("✅ Jogador autenticado: \(GKLocalPlayer.local.displayName)")
                DispatchQueue.main.async {
                    self.isAuthenticated = true
                }
                
                // Registrar para ouvir convites
                GKLocalPlayer.local.register(self)
                
                // Verificar se há convites pendentes após autenticação
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.processPendingInvite()
                }
                
            } else {
                print("❌ Falha ao autenticar: \(String(describing: error))")
                DispatchQueue.main.async {
                    self.isAuthenticated = false
                }
            }
        }
    }
    
     func addSubmission(_ submission: ImageSubmission) {
         imageSubmissions.append(submission)
         print(submission)
     }
    
     //MARK: ainda não está sendo chamada!!
    func startGame() {
         let playersCount = players.count
         game = Game(playersCount: playersCount)
        //vai pra phrasesView
        //enquanto nem todos tiverem mandado frase, espera.
        
     }
    
    // Adiciona frase e envia para todos os jogadores via Game Center
    func addPhrase(_ phrase: Phrase) {
        game?.addPhrase(phrase.text)
        // Envia a frase para os outros jogadores
        sendMessage("phrase:\(phrase.text)")
    }
    
    // Processar convite pendente (chamado automaticamente)
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
    
    // Aceitar convite
    private func acceptInvite(_ invite: GKInvite) {
        print("📩 Processando convite de \(invite.sender.displayName)")
        
        if let vc = GKMatchmakerViewController(invite: invite) {
            vc.matchmakerDelegate = self
            UIApplication.shared.currentRootViewController?.present(vc, animated: true)
        }
    }
    
    // Aceitar solicitação de partida
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
    
    // Matchmaking manual (botão Iniciar Partida)
    func startMatchmaking(minPlayers: Int = 1, maxPlayers: Int = 4, singlePlayerMode: Bool = false) {
        guard isAuthenticated else {
            print("⚠️ Usuário não está autenticado")
            return
        }
        
        // Handle single player mode
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
    
    
    // Create a single player match
    private func createSinglePlayerMatch() {
        print("✅ Starting single player match")
        
        DispatchQueue.main.async {
            self.isInMatch = true
            self.isSinglePlayer = true
            self.match = nil // No actual GKMatch for single player
            self.players = [GKLocalPlayer.local as GKPlayer]
            self.readyMap = [GKLocalPlayer.local.gamePlayerID: false]
            self.messages = ["Welcome to single player mode!"]
        }
    }
    
    // Enviar mensagem
    func sendMessage(_ text: String) {
        if isSinglePlayer {
            // In single player, just add to local messages
            DispatchQueue.main.async {
                self.messages.append("You: \(text)")
            }
            return
        }
        
        guard let match = match else {
            print("⚠️ Nenhuma partida ativa")
            return
        }
        
        let senderID = GKLocalPlayer.local.gamePlayerID
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
        let id = GKLocalPlayer.local.gamePlayerID
        let newValue = !(readyMap[id] ?? false)
        
        DispatchQueue.main.async {
            self.readyMap[id] = newValue
        }
        
        // In single player, don't try to send data
        if isSinglePlayer {
            return
        }
        
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
        let id = GKLocalPlayer.local.gamePlayerID
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
    
    private func refreshPlayers() {
        var everyone: [GKPlayer] = [GKLocalPlayer.local as GKPlayer]
        if let remotes = match?.players { everyone.append(contentsOf: remotes) }
        DispatchQueue.main.async {
            self.players = everyone
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
            self.players.removeAll()
            self.readyMap.removeAll()
            self.messages.removeAll()
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
            self.readyMap = map
        }
        
        sendMessage("Olá, galera!")
    }
    
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
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
    
//    func goToNextRound() {
//        guard let game = game, game.currentRoundIndex + 1 < game.rounds.count else { return }
//        self.game?.currentRoundIndex += 1
//    }
//    
//    // Retorna a rodada atual
//    func getCurrentRound() -> Round? {
//        return game?.currentRound
//    }
}

// MARK: - Listener de convites
extension GameCenterService: GKLocalPlayerListener {
    // Quando um convite é aceito pelo usuário FORA do app
    func player(_ player: GKPlayer, didAccept invite: GKInvite) {
        print("📩 Convite recebido de \(invite.sender.displayName)")
        
        // Armazenar o convite para processamento
        pendingInvite = invite
        
        // Se o app estiver ativo, processar imediatamente
        if UIApplication.shared.applicationState == .active {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.processPendingInvite()
            }
        }
        // Se o app não estiver ativo, será processado quando se tornar ativo
    }
    
    // Recebimento de solicitação de partida
    func player(_ player: GKPlayer, didRequestMatchWithRecipients recipientPlayers: [GKPlayer]) {
        print("📩 Solicitação de partida recebida para \(recipientPlayers.count) jogadores")
        
        // Armazenar a solicitação para processamento
        pendingPlayersToInvite = recipientPlayers
        
        // Se o app estiver ativo, processar imediatamente
        if UIApplication.shared.applicationState == .active {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.processPendingInvite()
            }
        }
        // Se o app não estiver ativo, será processado quando se tornar ativo
    }
}
