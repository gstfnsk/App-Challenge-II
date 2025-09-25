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
    enum PacketType: String, Codable { case chat, ready}
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

// MARK: - Game Center Helper
class GameCenterService: NSObject, ObservableObject {
    
    static let shared = GameCenterService()
    
    @Published var isAuthenticated = false
    @Published var isInMatch = false
    @Published var gamePlayers: [Player] = []
    //  @Published var players: [GKPlayer] = []
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
    @Published var submittedPhrasesByPlayer: [String: String] = [:] // Rastreador para frases por jogador
    
    var match: GKMatch?
    private var pendingInvite: GKInvite?
    private var pendingPlayersToInvite: [GKPlayer]?
    private var expectedPlayersCount: Int {
        if isSinglePlayer { return 1 }
        let ids = Set(([GKLocalPlayer.local] + (match?.players ?? [])).map { $0.gamePlayerID })
        return ids.count
    }
    
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
    
    //MARK: Define um startTime em comum (agora + 1 segundo) e envia para os jogadores
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
    //MARK: chamada ao receber dados
    func handleReceivedData(_ data: Data) {
        guard
            let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let type = dict["type"] as? String
        else { return }
        
        if type == "phaseStart", let ts = dict["date"] as? TimeInterval {
            timerStart = Date(timeIntervalSince1970: ts)
        }
    }
    
    // MARK: - Submissão de frases
    func submitPhrase(phrase: String) {
        let playerID = GKLocalPlayer.local.gamePlayerID
        // Evita sobrescrever caso já tenha submetido
        guard submittedPhrasesByPlayer[playerID] == nil else {
            print("⏭️ Ignorando submissão repetida de \(playerID)")
            return
        }
        
        submittedPhrasesByPlayer[playerID] = phrase
        phrases.append(phrase)
        
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
    }
    
    func ensureAllPlayersSubmittedFallback() {
        for player in gamePlayers {
            let playerID = player.player.gamePlayerID
            
            // Se já submeteu, ignora
            if submittedPhrasesByPlayer[playerID] != nil { continue }
            
            // Pega 1 frase aleatória do pool de 3 daquele player
            if let randomPhrase = localPhraseChoices[playerID]?.randomElement() {
                print("⚠️ Auto-submit forçado para \(player.player.displayName): \(randomPhrase)")
                submittedPhrasesByPlayer[playerID] = randomPhrase
                phrases.append(randomPhrase)
                submitPhrase(phrase: randomPhrase)
            }
            else if let backup = Phrases.all.randomElement()?.text {
                print("⚡ Fallback global para \(player.player.displayName): \(backup)")
                submittedPhrasesByPlayer[playerID] = backup
                phrases.append(backup)
                submitPhrase(phrase: backup)
            }
        }
    }

    
    // Função para eleger o líder da frase (jogador com menor ID)
    private func electPhraseLeader() -> String? {
        guard !gamePlayers.isEmpty else { return nil }
        
        // Ordena os jogadores por ID e pega o menor (que será o líder)
        let sortedPlayers = gamePlayers.sorted { $0.player.gamePlayerID < $1.player.gamePlayerID }
        return sortedPlayers.first?.player.gamePlayerID
    }
    
    func autoSubmitMissingPhrases() {
        let submittedPlayerIDs = Set(playerSubmissions.map { $0.player.gamePlayerID })

        for player in gamePlayers {
            let playerID = player.player.gamePlayerID

            if !submittedPlayerIDs.contains(playerID) {
                // Se o jogador não enviou frase, pegamos uma frase aleatória para ele
                if let randomPhrase = Phrases.all.randomElement() {
                    print("⚡ Auto-submit para jogador \(player.player.displayName): \(randomPhrase)")
                    submitPhrase(phrase: randomPhrase.text)
                }
            }
        }
    }
    
    // MARK: - Início da seleção de frase
    func initiatePhraseSelection() {
        // Antes de qualquer coisa, garantir que todos os jogadores têm uma frase
        ensureAllPlayersSubmittedFallback()
        
        if Phrases.all.isEmpty {
            print("⚠️ As frases disponíveis estão vazias em Phrases.all!")
            return
        }
        
        guard currentPhrase.isEmpty && phraseLeaderID == nil else {
            print("⚠️ Seleção de frase já em andamento ou frase já selecionada")
            return
        }
        
        let localID = GKLocalPlayer.local.gamePlayerID
        let leaderID = electPhraseLeader()
        
        guard let leaderID = leaderID else {
            print("❌ Não foi possível eleger um líder")
            return
        }
        
        // Define o líder
        phraseLeaderID = leaderID
        
        if isSinglePlayer {
            // Modo single player - seleciona a frase diretamente
            selectRandomPhrase()
        } else {
            // Modo multiplayer - envia a eleição do líder para todos
            broadcastPhraseLeader(leaderID)
            
            if localID != leaderID {
                isWaitingForPhrase = true
            }
            DispatchQueue.main.async { self.trySelectPhraseIfReady() }
        }
    }
    
    // Função para selecionar uma frase aleatória (apenas o líder)
    private func selectRandomPhrase() {
        if !currentPhrase.isEmpty {
                print("⚠️ Seleção já foi feita: \(currentPhrase)")
                return
            }
        
        guard !phrases.isEmpty else {
            print("❌ Nenhuma frase disponível para seleção")
            return
        }
        
        if let selectedPhrase = phrases.randomElement() {
            currentPhrase = selectedPhrase
            print("🎯 Líder selecionou a frase: \(selectedPhrase)")
            
            // Envia a frase selecionada para todos os jogadores
            broadcastSelectedPhrase(selectedPhrase)
        }
    }
    
    // Função para enviar a eleição do líder
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
    
    // Função para enviar a frase selecionada
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
    
    // Função legada mantida para compatibilidade
    func setCurrentRandomPhrase() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.initiatePhraseSelection()
        }
    }
    
    func getCurrentRandomPhrase() -> String {
        return self.currentPhrase
    }
    
    func haveAllPlayersSubmittedImage() -> Bool {
        print(playerSubmissions)
        return ((gamePlayers.count == playerSubmissions.count && gamePlayers.count != 0) ? true : false)
    }
    
    //MARK: submissão de imagem do jogador para a frase atual
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
    
    
    func haveAllPlayersSubmittedPhrase() -> Bool {
        print("\(phrases)")
        return (gamePlayers.count == submittedPhrasesByPlayer.count && gamePlayers.count != 0)
        
    }
    
    func getSubmittedImages() -> [PlayerSubmission] {
        return self.playerSubmissions
    }
    
    //MARK: Rodadas:
    var maxRounds: Int {
        gamePlayers.count
    }
    
    func goToNextRound() {
        if currentRound < maxRounds {
            currentRound += 1
            // Resetar estado da frase para a nova rodada
            resetPhraseState()
        }
    }
    
    // Função para resetar o estado da frase
    private func resetPhraseState() {
            currentPhrase = ""
            phraseLeaderID = nil
            isWaitingForPhrase = false
            submittedPhrasesByPlayer.removeAll()
            phrases.removeAll()
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
            self.gamePlayers = [Player(player: GKLocalPlayer.local)]
            //  self.players = [GKLocalPlayer.local]
            self.readyMap = [GKLocalPlayer.local.gamePlayerID: false]
            self.messages = ["Welcome to single player mode!"]
            self.phrases = []
            
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
    
    private func trySelectPhraseIfReady() {
        guard currentPhrase.isEmpty else { return }
        guard let leaderID = phraseLeaderID else { return }

        let expected = expectedPlayersCount
        let haveAll = phrases.count >= expected && expected > 0
        guard haveAll else { return }

        if GKLocalPlayer.local.gamePlayerID == leaderID {
            selectRandomPhrase()
        } else {
            DispatchQueue.main.async { self.isWaitingForPhrase = true }
        }
    }
    
    private func refreshPlayers() {
        var everyone: [GKPlayer] = [GKLocalPlayer.local as GKPlayer]
        if let remotes = match?.players { everyone.append(contentsOf: remotes) }
        DispatchQueue.main.async {
            
            for player in everyone {
                let gamePlayer = Player(player: player)
                self.gamePlayers.append(gamePlayer)
            }
            
            //  self.players = everyone
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
            return // Se conseguiu decodificar como LobbyPacket, não precisa continuar
        }
        
        // Segundo: tentar decodificar como JSON genérico (mensagens do jogo)
        guard
            let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let type = dict["type"] as? String
        else {
            // Se não conseguiu decodificar como nenhum dos dois, tenta como texto simples
            if let text = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.messages.append("\(player.displayName): \(text)")
                }
            }
            return
        }
        
        // Processar mensagens específicas do jogo
        switch type {
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
        case "newPhrase":
            if let phrase = dict["phrase"] as? String {
                let senderID = player.gamePlayerID
                
                DispatchQueue.main.async {
                    // Adicionar à lista de frases se ainda não existe
                    if !self.phrases.contains(phrase) {
                        self.phrases.append(phrase)
                        print("📡 Frase '\(phrase)' recebida de \(player.displayName)")
                    }
                    
                    // IMPORTANTE: Atualizar o dicionário de submissões
                    if self.submittedPhrasesByPlayer[senderID] == nil {
                        self.submittedPhrasesByPlayer[senderID] = phrase
                        print("🔄 Atualizando submissão do jogador \(player.displayName): \(phrase)")
                    } else {
                        print("⏭️ Jogador \(player.displayName) já tinha submetido uma frase")
                    }
                }
            }
        case "phaseStart":
            if let ts = dict["date"] as? TimeInterval {
                DispatchQueue.main.async {
                    self.timerStart = Date(timeIntervalSince1970: ts)
                }
            }
        default:
            print("⚠️ Tipo de mensagem desconhecido: \(type)")
            break
        }
    }
    
    func match(_ match: GKMatch, didFailWithError error: Error?) {
        print("❌ Erro no match: \(error?.localizedDescription ?? "desconhecido")")
        leaveMatch()
    }
    
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
